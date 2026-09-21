# Telegram Bot API → Swift

Both generated layers in this package are produced from a committed snapshot of
Telegram's own documentation:

```
botapi/telegram-bot-api.html          the snapshot (https://core.telegram.org/bots/api)
botapi/snapshot.json                  source, sha256, Bot API version and date
  └─ Tooling/BotAPIGen ──► Sources/TelegramBotAPI/Generated/<Section>/<Type>.swift
                      └──► Sources/TelegramBotKit/Generated/TelegramBotClient+*.swift
                                                            UpdateKind.swift
```

The generator is a package of its own under `Tooling/BotAPIGen`, outside the
main graph. Not because its sources are large — a consumer clones the whole
repository either way — but so the library's manifest declares only what the
library needs. Its one dependency, swift-crypto, exists to checksum the
snapshot and has no business in a Telegram bot framework's dependency list.

## Regenerating

```bash
Scripts/generate-api.sh              # from the committed snapshot — offline
Scripts/generate-api.sh --refresh    # re-download the documentation first
```

The default run never touches the network and produces the same bytes every
time. `--refresh` downloads the page and rewrites `snapshot.json`, so adopting a
new Bot API version is an explicit commit of the snapshot alongside the
regenerated sources. `Scripts/verify-generated.sh` runs the pipeline twice,
fails on any difference, and also fails if generation modified its own input.

Every generated file carries a header naming the Bot API revision it came from,
and `BotAPIVersion.version` / `.releaseDate` expose the same values at runtime.

When reviewing a Bot API bump, `--dump-ir <file>` writes everything the parser
read as JSON. Diffing two of those shows exactly which types, fields and return
types changed, without reading a 19k-line Swift diff.

## What the parser reads

The documentation page is flat and regular, which is what makes parsing it
safer than it sounds. Measured against Bot API 10.3:

| | |
|---|---|
| `<h3>` sections | 14, of which 10 carry API surface |
| `<h4>` entries in those | 595 → 400 types, 185 methods, 10 prose asides |
| Tables | 365 `Field/Type/Description`, 177 `Parameter/Type/Required/Description` |
| Table-less entries | 26 unions, 8 empty objects, 8 zero-parameter methods, `InputFile` |
| Table rows | 2,820, using 225 distinct type strings |

No `<h4>` section contains more than one table, so "the first table after the
heading" is unambiguous — and that is asserted, not assumed.

### Four small grammars

**Type strings.** The Type column uses a tiny grammar, and anything outside it
is a hard failure rather than a guess:

```
type      ::= "Array of " type | irregular | orChain | primitive | Name
irregular ::= "Array of " Name ("," Name)* " and " Name     one site
orChain   ::= Name (" or " Name)+
primitive ::= String | Integer | Boolean | Float | True
```

An `or` chain resolves to `ChatId` (`Integer or String`, 100 sites), to
`FileInput` (`InputFile or String`), to a documented union whose variant set
matches exactly, or to one of two unions Telegram only ever spells out inline —
`MediaGroupInputMedia` and `RichMessageInputMedia`. Nothing else is accepted.

**Optionality** needs no heuristic: a field is optional exactly when its
description opens with `<em>Optional</em>.`, and a parameter is required
exactly when its Required cell reads `Yes`.

**Return types** are the one place the generator reads English. Thirteen
ordered patterns are tried against the whole method description, and a match
only counts when the name it captured is a type the page documents — which is
what stops `getWebhookInfo`'s trailing *"will return an object with the url
field empty"* from winning. All 185 methods resolve, or generation fails.

**Accepted values.** Some `String` fields spell out what they accept — "Type of
the chat, can be either “private”, “group”, “supergroup” or “channel”" — and
those become real enums rather than staying stringly typed. The list only counts
when a phrase makes it *this field's* value (`can be`, `must be`, `one of`);
`for example` and `e.g.` mark an illustration, not a closed set, so
`VideoQuality.codec` stays a `String`.

A union's discriminator is the same thing written one variant at a time —
`InlineQueryResultArticle.type` always carries `article` — so each union also
gets a `<Union>Kind` enum shared by its variants, and the field defaults to the
right case. `BotCommandScopeChat(chatId: …)` needs no `type:` argument at all.
49 enums over ~130 fields today.

Every one carries an `unknown(String)` case. Telegram adds values between
releases, and an enum that threw on an unrecognised one would turn a new chat
type into a dropped update.

**Discriminators** come from the variant's own field description: `always
“creator”` or `must be *default*` (the emphasis is required, so "must be
positive" cannot match). A key is promoted only when it covers every variant
**and** its values are pairwise distinct. `InlineQueryResult` fails the second
test — it reuses `audio`, `document`, `gif`, `mpeg4_gif`, `photo`, `video` and
`voice` across its cached and non-cached forms — so it decodes by trying each
variant instead. Without that check the enum would have duplicate case names
and a decoder that silently picked the wrong one.

### The one documented deviation

`RichText`'s prose adds alternatives its `<ul>` omits: *"it can be either a
String for plain text, an Array of RichText, or any of the following types"*.
Those are mined from the sentence, and it is asserted that exactly one union
does this and that it is `RichText`. A second one fails generation so a human
decides.

## Generated shape

**Types** land in `Sources/TelegramBotAPI/Generated`, one file per type, in a
folder named after the documentation section it came from:

```
AvailableTypes/   235   GettingUpdates/    2   Shared/    4   Support/  2
RichMessages/      85   Payments/         25   Stickers/  4   Games/    3
InlineMode/        31   TelegramPassport/ 14   Values/   49
```

`Values/` holds the enums recovered from field descriptions; `Shared/` the
unions Telegram only spells out inline. A file is named exactly after the type
it declares, so a type is where you would look for it, and a spec bump produces
a diff you can read.

They are plain `public struct X: Codable, Hashable, Sendable` with document-order
memberwise initialisers. A union variant's discriminator is typed and defaults
to the case it always carries, so `BotCommandScopeDefault()` needs no arguments.
They
**import nothing at all** — `Codable`, `Hashable`
and `Sendable` are standard library. That is what makes flat top-level names
safe: with no Foundation import there is no `Data`/`Operation`/`Progress`/`Timer`
to collide with.

Unions become enums. A discriminated one reads its key once and switches, with
cases named after the wire value (`ChatMemberOwner` → `.creator`). The three
undiscriminated ones try each variant in `<ul>` order, with cases named after
the variant type.

**Storage.** Two separate problems are solved by putting a value behind a box:

- *Cycles*: a `Message` carries the `Message` it replies to. Arrays are not
  edges, so only direct fields loop; unions in a cycle become `indirect`
  (`RichText`, `MaybeInaccessibleMessage`) and the remaining nine back edges
  are boxed fields.
- *Size*: left inline, `Message` lays out at about 17 KB and `Update` — which
  holds seven `Message` fields — at roughly **125 KB**, which overflows the
  stack when passed by value. Fields referencing an oversized type are boxed
  too. `Update` is now 224 bytes and `Message` 2.3 KB.

Boxing individual fields keeps the public API identical — the property keeps its
type, only its storage moves.

**Methods** land in `Sources/TelegramBotKit/Generated`, grouped into seven
files. Each is one `set` per documented parameter and a single `perform`, about
3.9k lines in total.

## Transport

`TelegramBotClient` talks to Telegram through ``TelegramTransport``: one method,
an `HTTPRequest` from swift-http-types, and `Data` in and out. Bodies are `Data`
rather than a byte stream because every request the encoder builds is already a
complete buffer and every response is decoded whole — so nothing is gained by
streaming, and every request becomes trivially replayable, which is what lets
the flood-wait middleware retry without asking whether a body can be read twice.

`AsyncHTTPClientTelegramTransport` is the default implementation; tests
substitute their own. `TelegramMiddleware` wraps the same signature and is how
rate limiting and flood-wait retry are applied.

## Wire format

JSON is the default; `multipart/form-data` is used **only when a call actually
uploads bytes**. Telegram accepts a JSON body for every method, so multipart is
not worth its overhead otherwise — and it avoids the string coercion multipart
forces on `chat_id` and every boolean. Within a multipart request, arrays and
objects go as a single JSON-serialised part, because Telegram rejects repeated
parts.

Known gap, deliberately not addressed here: Telegram's `attach://<name>`
convention for uploading files nested inside `InputMedia`, `InputSticker` or
`InputStoryContent`. `sendMediaGroup` therefore works with `file_id` and URL
media only. `TelegramRequest` makes this a natural addition later.

## Deliberately not generated

`ParseMode`, `ChatAction` and `FileInput` are hand-written in
`Sources/TelegramBotKit/TelegramVocabulary.swift`. Their values live in prose
sections the parser skips entirely — `ParseMode`'s in "Formatting options",
`ChatAction`'s in an unquoted sentence — so there is no list to read.
(`ChatType` used to be here too; it is now generated from `Chat.type`.)

## Fail-loud invariants

`Tooling/BotAPIGen/Sources/BotAPIGen/Invariants.swift` asserts the page still
has the shape the generator was written against. Counts that legitimately grow
(types, methods, rows) get ranges; anything about *resolution* is exact, because
a near miss there is a silently wrong Swift signature:

- every type string parses and every name resolves to a documented type;
- all 185 methods resolve a return type;
- every union variant set resolves; exactly two synthesized unions exist;
- exactly one union carries extra prose alternatives, and it is `RichText`;
- exactly two unions lack a discriminator and exactly one is demoted for
  duplicate values;
- the list of field-less types matches exactly — a prose section whose title
  happens to have no space in it looks just like one, and would otherwise be
  absorbed as a junk empty struct;
- every value enum the public API depends on is still recovered *and* has not
  shrunk — a new enum or a new case is fine, but a vanished enum means a
  reworded sentence turned a typed field back into a `String`, and a lost case
  would be hidden at runtime by `unknown(String)`;
- the recursion-boxed field list matches exactly, and no type exceeds the size
  cap;
- `fieldTables + unions + emptyObjects + InputFile == parsed types`, exactly;
- the snapshot's SHA-256 and Bot API version match `snapshot.json`.

Every failure names the construct and the expected range.

## Behaviour on a Bot API change

Additive changes flow through with no code change: a new type becomes a new
file, a new field appears on its struct, a new method gets a signature with its
return type and pacing, a new union variant becomes a case, and a new value in
a documented list becomes an enum case.

Anything the generator cannot read stops it, naming the exact place: an
unparsable type string reports `Update.update_id`, a dangling type reference
reports `Message.entities`, an unreadable return type reports the method. The
invariants cover the quieter failures — a reworded value list, a lost enum
case, a prose section masquerading as a type.

What still needs a human: a genuinely new construct in the page (a new table
shape, a new way of writing unions), and any change where prose stays
grammatical but means something different.

## Build cost

Clean debug build of the `TelegramBotAPI` target, Apple Silicon: **~3.5 s**
(7.1 s wall including package planning), against the **~81 s** recorded for the
previous OpenAPI-generated layer.

Splitting the same code across 437 files rather than 15 cost about 0.7 s, so
file granularity is not what drives the number — the 64k-line single file was.
