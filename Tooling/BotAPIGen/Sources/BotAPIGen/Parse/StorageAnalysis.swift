/// Decides how each field is stored.
///
/// Two problems have the same answer — put the value behind a reference — and
/// both have to be solved or the generated types are unusable.
///
/// **Cycles.** Telegram's object graph loops: a `Message` carries the `Message`
/// it replies to. Arrays are not edges, because `[X]` is already a heap buffer,
/// so only direct fields and union payloads can form a value-type cycle.
///
/// **Size.** Left alone, `Message` lays out at about 17 KB and `Update` — which
/// holds seven `Message` fields inline — at roughly 125 KB. Passing one of
/// those by value overflows the stack. The previous pipeline dealt with this by
/// putting `Message`'s entire storage behind a copy-on-write box and forwarding
/// every property through it, which cost that one type about 120 forwarding
/// pairs. Boxing the handful of oversized *fields* instead achieves the same
/// bound for a fraction of the generated code, and leaves the public API
/// identical: the property keeps its type, only its storage moves.
enum StorageAnalysis {
    /// A field referencing a type estimated larger than this is boxed.
    ///
    /// The exact figure is not load-bearing; what matters is that it is far
    /// below the stack budget and far above the size of an ordinary Telegram
    /// object such as `User` or `Chat`, so the common cases stay inline.
    static let inlineSizeLimit = 128

    /// The cap every type must satisfy once the analysis has run. Asserted by
    /// `Invariants` as a property rather than as a list, so a future Bot API
    /// that adds a large field is bounded automatically.
    ///
    /// It cannot go much lower without boxing whole types: `Message` alone
    /// documents about 120 optional fields, and an optional costs its tag even
    /// when its payload is a pointer, so a few kilobytes is the floor.
    static let maximumEstimatedSize = 4 * 1024

    static func apply(to spec: inout ApiSpec, statistics: inout ParseStatistics) {
        let order = spec.types.map(\.name)
        var byName = spec.typesByName

        // --- Pass 1: cycles -------------------------------------------------

        var indirectUnions: Set<String> = []
        for component in self.stronglyConnectedComponents(order: order, types: byName) {
            let loops = component.count > 1 || self.hasSelfEdge(component[0], types: byName)
            guard loops else { continue }
            for name in component where byName[name]?.union != nil {
                indirectUnions.insert(name)
            }
        }

        var cycleBoxed: [String] = []
        for edge in self.backEdges(order: order, types: byName, cut: indirectUnions) {
            guard byName[edge.owner]?.union == nil else {
                // A union still closing a cycle after pass 1 would mean the two
                // passes disagree. Cut it too and let the invariants report it.
                indirectUnions.insert(edge.owner)
                continue
            }
            Self.box(owner: edge.owner, field: edge.member, in: &byName)
            cycleBoxed.append("\(edge.owner).\(edge.member)")
        }

        // --- Pass 2: size ---------------------------------------------------

        var sizeBoxed: [String] = []
        while true {
            let sizes = self.estimateSizes(order: order, types: byName, indirect: indirectUnions)
            var changed = false
            for name in order {
                guard case let .object(fields)? = byName[name]?.shape else { continue }
                for field in fields where !field.needsBoxing {
                    guard let referenced = field.type.directReferences.first,
                          let size = sizes[referenced],
                          size > Self.inlineSizeLimit
                    else { continue }
                    Self.box(owner: name, field: field.swiftName, in: &byName)
                    sizeBoxed.append("\(name).\(field.swiftName)")
                    changed = true
                }
            }
            if !changed { break }
        }

        spec.types = order.compactMap { byName[$0] }
        spec.indirectUnions = indirectUnions
        spec.estimatedSizes = self.estimateSizes(
            order: order, types: byName, indirect: indirectUnions
        )
        statistics.indirectUnions = indirectUnions.sorted()
        statistics.cycleBoxedFields = cycleBoxed.sorted()
        statistics.sizeBoxedFieldCount = sizeBoxed.count
        statistics.largestEstimatedSize = spec.estimatedSizes.values.max() ?? 0
    }

    private static func box(owner: String, field: String, in types: inout [String: ApiType]) {
        guard case var .object(fields)? = types[owner]?.shape,
              let index = fields.firstIndex(where: { $0.swiftName == field })
        else { return }
        fields[index].needsBoxing = true
        types[owner]?.shape = .object(fields)
    }

    // MARK: - Size estimation

    /// A rough but deterministic stand-in for Swift's layout algorithm. It only
    /// has to be good enough to separate "a handful of scalars" from "a type
    /// that must not be copied onto the stack".
    private static func estimateSizes(
        order: [String],
        types: [String: ApiType],
        indirect: Set<String>
    ) -> [String: Int] {
        var sizes: [String: Int] = [:]
        var inProgress: Set<String> = []

        func size(of name: String) -> Int {
            if let known = sizes[name] { return known }
            guard let type = types[name] else { return 8 }
            // Boxes and indirect enums break every cycle, so this recursion
            // terminates; the guard is belt and braces.
            guard inProgress.insert(name).inserted else { return 8 }
            defer { inProgress.remove(name) }

            let result: Int
            switch type.shape {
            case .empty:
                result = 1
            case let .object(fields):
                result = fields.reduce(0) { total, field in
                    total + (field.needsBoxing ? 8 : self.stride(of: size(of: field.type), optional: field.isOptional))
                }
            case let .union(union):
                let payload = indirect.contains(name)
                    ? 8
                    : union.variants.map(size(of:)).max() ?? 0
                result = max(payload, union.extraAlternatives.map(size(of:)).max() ?? 0) + 1
            }
            sizes[name] = result
            return result
        }

        func size(of type: FieldType) -> Int {
            switch type {
            case .string: 16
            case .integer, .float: 8
            case .boolean, .trueLiteral: 1
            case .array: 8
            case .chatId: 24
            case .fileOrString: 16
            // A closed set plus an `unknown(String)` payload.
            case .valueEnum: 17
            case .named(let name): size(of: name)
            }
        }

        for name in order { _ = size(of: name) }
        return sizes
    }

    /// Rounds a field's contribution up the way Swift's layout does, and gives
    /// an optional room for its tag. Deliberately generous: the estimate is
    /// only useful if it never claims a type is smaller than it really is.
    private static func stride(of size: Int, optional: Bool) -> Int {
        let padded = (size + 7) / 8 * 8
        return optional ? padded + 8 : padded
    }

    // MARK: - Cycle detection

    private struct Edge {
        var owner: String
        /// The Swift property name for a struct, the variant name for a union.
        var member: String
        var target: String
    }

    private static func edges(from type: ApiType) -> [Edge] {
        switch type.shape {
        case let .object(fields):
            fields.flatMap { field in
                field.type.directReferences.map {
                    Edge(owner: type.name, member: field.swiftName, target: $0)
                }
            }
        case let .union(union):
            union.variants.map { Edge(owner: type.name, member: $0, target: $0) }
                + union.extraAlternatives.flatMap { alternative in
                    alternative.directReferences.map {
                        Edge(owner: type.name, member: $0, target: $0)
                    }
                }
        case .empty:
            []
        }
    }

    private static func hasSelfEdge(_ name: String, types: [String: ApiType]) -> Bool {
        guard let type = types[name] else { return false }
        return self.edges(from: type).contains { $0.target == name }
    }

    /// Tarjan's algorithm, iterating in document order so the components — and
    /// therefore the generated output — are identical on every run.
    private static func stronglyConnectedComponents(
        order: [String],
        types: [String: ApiType]
    ) -> [[String]] {
        var index: [String: Int] = [:]
        var lowLink: [String: Int] = [:]
        var onStack: Set<String> = []
        var stack: [String] = []
        var counter = 0
        var components: [[String]] = []

        func strongConnect(_ name: String) {
            index[name] = counter
            lowLink[name] = counter
            counter += 1
            stack.append(name)
            onStack.insert(name)

            for edge in types[name].map(self.edges(from:)) ?? [] {
                guard types[edge.target] != nil else { continue }
                if index[edge.target] == nil {
                    strongConnect(edge.target)
                    lowLink[name] = min(lowLink[name]!, lowLink[edge.target]!)
                } else if onStack.contains(edge.target) {
                    lowLink[name] = min(lowLink[name]!, index[edge.target]!)
                }
            }

            if lowLink[name] == index[name] {
                var component: [String] = []
                while let top = stack.popLast() {
                    onStack.remove(top)
                    component.append(top)
                    if top == name { break }
                }
                components.append(component)
            }
        }

        for name in order where index[name] == nil { strongConnect(name) }
        return components
    }

    /// Depth-first walk collecting back edges — an edge whose target is still on
    /// the current path, i.e. the edge that closes a cycle. Edges leaving a
    /// type in `cut` are not followed.
    private static func backEdges(
        order: [String],
        types: [String: ApiType],
        cut: Set<String>
    ) -> [Edge] {
        var state: [String: Int] = [:]  // 0 unvisited, 1 on path, 2 done
        var found: [Edge] = []
        var seen: Set<String> = []

        func visit(_ name: String) {
            state[name] = 1
            if let type = types[name], !cut.contains(name) {
                for edge in self.edges(from: type) {
                    guard types[edge.target] != nil else { continue }
                    switch state[edge.target] ?? 0 {
                    case 1:
                        let key = "\(edge.owner).\(edge.member)"
                        if seen.insert(key).inserted { found.append(edge) }
                    case 0:
                        visit(edge.target)
                    default:
                        break
                    }
                }
            }
            state[name] = 2
        }

        for name in order where (state[name] ?? 0) == 0 { visit(name) }
        return found
    }
}
