# Telegram Bot API OpenAPI toolchain

`Sources/TelegramBotAPI/Generated` is committed output of Apple's
[swift-openapi-generator](https://github.com/apple/swift-openapi-generator),
produced from the spec in this directory. Consumers of Teleroute never build
the generator — they only need `swift-openapi-runtime` plus a transport.

## Files

- `telegram-bot-api.json` — pristine spec (Bot API 10.3, OpenAPI 3.0.0).
- `telegram-bot-api.patched.json` — output of `Scripts/patch-openapi.py`
  (committed so diffs of spec updates stay reviewable).
- `openapi-generator-config.yaml` — generator config
  (`types` + `client`, `accessModifier: public`, `namingStrategy: idiomatic`).

## Regenerating

```bash
Scripts/generate-api.sh
```

The script patches the spec and runs the generator pinned by
`Tooling/APIGen/Package.swift` (`exact` version) + `Tooling/APIGen/Package.resolved`.
Bump the pin deliberately, rerun the script, and commit spec, patched spec,
and generated sources together. The script is idempotent: running it twice
must leave `git status` clean.

## Spec patches (`Scripts/patch-openapi.py`)

1. **Inline single-`$ref` `allOf` wrappers** (554 sites) — without this every
   nested object property generates a wrapper struct accessed via `.value1`.
2. **Hoist `oneOf [int64, string]`** (100 sites: `chat_id`, `from_chat_id`, …)
   into the shared `#/components/schemas/ChatId`.
3. **Hoist the 4-variant `reply_markup` oneOf** (18 sites) into the shared
   `#/components/schemas/ReplyMarkup`.
4. **`InputFile`** — the upstream spec declares it as an empty `object`;
   rewritten to `{type: string, format: binary}` so multipart file parts get
   a usable `HTTPBody` type.

The patcher asserts minimum match counts for each rewrite so silent spec-shape
drift fails loudly instead of degrading the generated API.

## Multipart decision (spike record, 2026-08-30)

The 33 multipart-only operations (`sendPhoto`, `editMessageText`,
`sendMediaGroup`, …) generate cleanly with patch 4 in place ("Attempt A" of
the migration plan): scalar and file parts are raw `HTTPBody` parts (accepting
either a `file_id`/URL string or raw bytes with a filename), object parts such
as `reply_markup` are typed JSON payloads. No JSON-body fallback patch and no
hand-written multipart encoder are needed.

## Build cost

Clean debug build of the `TelegramBotAPI` target (Types.swift ~64k lines,
Client.swift ~19k lines): **~81 s** on an Apple Silicon M-series machine.
The target builds once and is cached; it deliberately uses minimal
`swiftSettings` (plain Swift 6 language mode, none of the package's
upcoming-feature flags).
