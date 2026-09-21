import Foundation

/// Counts gathered while parsing, so `Invariants` can assert the documentation
/// still has the shape the generator was written against.
struct ParseStatistics {
    var sectionTitles: [String] = []
    var apiEntryCount = 0
    var proseTitles: [String] = []
    var fieldTableCount = 0
    var parameterTableCount = 0
    var unionCount = 0
    var emptyStructCount = 0
    var emptyStructNames: [String] = []
    var zeroParameterMethodCount = 0
    var inputFileEntryCount = 0
    var tableRowCount = 0
    var sectionsWithMultipleTables: [String] = []
    var inlineUnionResolutions: [String: Int] = [:]
    var unionsWithExtraAlternatives: [String] = []
    var unionsWithoutDiscriminator: [String] = []
    var unionsDemotedForDuplicateValues: [String] = []
    var chatIdOccurrences = 0
    var replyMarkupOccurrences = 0
    var fileInputParameterCount = 0
    var fileInputMethodCount = 0
    var parseModeMethodCount = 0
    var chatActionParameterCount = 0
    var valueEnumNames: [String] = []
    var valueEnumCaseCounts: [String: Int] = [:]
    var valueEnumFieldCount = 0
    var indirectUnions: [String] = []
    /// Fields boxed to break a value-type cycle.
    var cycleBoxedFields: [String] = []
    /// Fields boxed because the type they reference is too large to pass inline.
    var sizeBoxedFieldCount = 0
    var largestEstimatedSize = 0
}

/// Drives the HTML layer into the IR.
struct SpecParser {
    let html: String
    let sha256: String

    func parse() throws -> (spec: ApiSpec, statistics: ParseStatistics) {
        var stats = ParseStatistics()
        let document = try DocumentSlicer.slice(self.html)
        stats.sectionTitles = document.sectionTitles

        let (version, date) = try Self.botApiVersion(in: document)

        let apiEntries = document.entries.filter {
            KnownDeviations.apiSections.contains($0.section)
        }
        stats.apiEntryCount = apiEntries.count

        var typeEntries: [RawEntry] = []
        var methodEntries: [RawEntry] = []
        for entry in apiEntries {
            if entry.title.contains(" ") {
                stats.proseTitles.append(entry.title)
            } else if entry.title.first?.isUppercase == true {
                typeEntries.append(entry)
            } else {
                methodEntries.append(entry)
            }
            if TableReader.tableCount(in: entry.content) > 1 {
                stats.sectionsWithMultipleTables.append(entry.title)
            }
        }

        // --- Names -------------------------------------------------------

        var knownTypes = Set(typeEntries.map(\.title))
        knownTypes.remove("InputFile")  // a parameter type only; never a field
        knownTypes.insert(KnownDeviations.replyMarkup.name)
        for synthesized in KnownDeviations.synthesizedUnions {
            knownTypes.insert(synthesized.name)
        }
        let inlineText = InlineText(knownTypes: knownTypes)

        // --- Union registry ----------------------------------------------

        var documentOrder: [String] = []
        var documentedUnions: [(entry: RawEntry, variants: [String])] = []
        var emptyStructEntries: [RawEntry] = []
        var objectEntries: [(entry: RawEntry, table: RawTable)] = []

        for entry in typeEntries {
            if entry.title == "InputFile" {
                stats.inputFileEntryCount += 1
                continue
            }
            documentOrder.append(entry.title)
            if let table = try TableReader.firstTable(in: entry.content) {
                stats.fieldTableCount += 1
                stats.tableRowCount += table.rows.count
                objectEntries.append((entry, table))
                continue
            }
            let variants = try TableReader.linkList(in: entry.content)
            if variants.isEmpty {
                stats.emptyStructCount += 1
                stats.emptyStructNames.append(entry.title)
                emptyStructEntries.append(entry)
            } else {
                stats.unionCount += 1
                documentedUnions.append((entry, variants))
            }
        }

        var unionsByVariants: [Set<String>: String] = [:]
        for union in documentedUnions {
            unionsByVariants[Set(union.variants)] = union.entry.title
        }
        unionsByVariants[KnownDeviations.replyMarkup.variants] = KnownDeviations.replyMarkup.name
        for synthesized in KnownDeviations.synthesizedUnions {
            unionsByVariants[synthesized.variants] = synthesized.name
        }

        var grammar = TypeGrammar(knownTypes: knownTypes, unionsByVariants: unionsByVariants)

        // --- Object types --------------------------------------------------

        var typesByName: [String: ApiType] = [:]

        for (entry, table) in objectEntries {
            try Self.expectHeaders(table, ["Field", "Type", "Description"], entry: entry)
            var fields: [ApiField] = []
            for row in table.rows {
                guard row.count >= 3 else {
                    throw GeneratorError("short field row in '\(entry.title)'")
                }
                let field = try Self.makeField(
                    wireName: try HTMLScanner.plainText(row[0]),
                    typeString: try HTMLScanner.plainText(row[1]),
                    descriptionHTML: row[2],
                    isOptional: Self.isOptionalField(row[2]),
                    owner: entry.title,
                    grammar: &grammar,
                    inlineText: inlineText,
                    statistics: &stats
                )
                fields.append(field)
            }
            let type = ApiType(
                name: entry.title,
                section: entry.section,
                doc: try inlineText.markdown(TableReader.leadingParagraphs(in: entry.content).joined(separator: "\n")),
                shape: .object(fields)
            )
            typesByName[type.name] = type
        }

        for entry in emptyStructEntries {
            let type = ApiType(
                name: entry.title,
                section: entry.section,
                doc: try inlineText.markdown(TableReader.leadingParagraphs(in: entry.content).joined(separator: "\n")),
                shape: .empty
            )
            typesByName[type.name] = type
        }

        // --- Unions ---------------------------------------------------------

        for (entry, variants) in documentedUnions {
            let outcome = DiscriminatorFinder.find(variants: variants, types: typesByName)
            let extras = try Self.extraAlternatives(
                unionName: entry.title,
                paragraphs: TableReader.leadingParagraphs(in: entry.content),
                grammar: &grammar
            )
            if !extras.isEmpty { stats.unionsWithExtraAlternatives.append(entry.title) }
            if outcome.demotedForDuplicateValues {
                stats.unionsDemotedForDuplicateValues.append(entry.title)
            } else if outcome.discriminator == nil {
                stats.unionsWithoutDiscriminator.append(entry.title)
            }
            let type = ApiType(
                name: entry.title,
                section: entry.section,
                doc: try inlineText.markdown(TableReader.leadingParagraphs(in: entry.content).joined(separator: "\n")),
                shape: .union(
                    ApiUnion(
                        variants: variants,
                        extraAlternatives: extras,
                        discriminator: outcome.discriminator,
                        demotedForDuplicateValues: outcome.demotedForDuplicateValues,
                        foundDiscriminator: outcome.found
                    )
                )
            )
            typesByName[type.name] = type
        }

        // Document order, then the unions Telegram only spells out inline.
        var orderedTypes = documentOrder.compactMap { typesByName[$0] }
        for synthesized in Self.synthesizedUnionTypes(typesByName: typesByName) {
            typesByName[synthesized.name] = synthesized
            orderedTypes.append(synthesized)
        }

        // --- Methods ---------------------------------------------------------

        let returnGrammar = ReturnGrammar(knownTypes: knownTypes)
        var methods: [ApiMethod] = []
        for entry in methodEntries {
            let paragraphs = TableReader.leadingParagraphs(in: entry.content)
            let plainDescription = try HTMLScanner.plainText(paragraphs.joined(separator: " "))
            var parameters: [ApiParameter] = []
            if let table = try TableReader.firstTable(in: entry.content) {
                try Self.expectHeaders(table, ["Parameter", "Type", "Required", "Description"], entry: entry)
                stats.parameterTableCount += 1
                stats.tableRowCount += table.rows.count
                for row in table.rows {
                    guard row.count >= 4 else {
                        throw GeneratorError("short parameter row in '\(entry.title)'")
                    }
                    let wireName = try HTMLScanner.plainText(row[0])
                    let typeString = try HTMLScanner.plainText(row[1])
                    let required = try HTMLScanner.plainText(row[2]) == "Yes"
                    let field = try Self.makeField(
                        wireName: wireName,
                        typeString: typeString,
                        descriptionHTML: row[3],
                        isOptional: !required,
                        owner: entry.title,
                        grammar: &grammar,
                        inlineText: inlineText,
                        statistics: &stats
                    )
                    parameters.append(
                        ApiParameter(
                            field: field,
                            sugar: Self.sugar(method: entry.title, field: field, statistics: &stats)
                        )
                    )
                }
            } else {
                stats.zeroParameterMethodCount += 1
            }
            if parameters.contains(where: { $0.sugar == .fileInput }) {
                stats.fileInputMethodCount += 1
            }
            if parameters.contains(where: { $0.sugar == .parseMode }) {
                stats.parseModeMethodCount += 1
            }
            methods.append(
                ApiMethod(
                    name: entry.title,
                    section: entry.section,
                    doc: try inlineText.markdown(paragraphs.joined(separator: "\n")),
                    parameters: parameters,
                    returnType: try returnGrammar.parse(description: plainDescription, method: entry.title),
                    group: Self.group(for: entry.title)
                )
            )
        }

        stats.inlineUnionResolutions = grammar.resolvedInlineUnions

        var spec = ApiSpec(
            botApiVersion: version,
            botApiDate: date,
            sourceSHA256: self.sha256,
            types: orderedTypes,
            methods: methods
        )
        ValueEnumAnalysis.apply(to: &spec, statistics: &stats)
        StorageAnalysis.apply(to: &spec, statistics: &stats)
        return (spec, stats)
    }
}
