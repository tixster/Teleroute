#!/usr/bin/env bash
# Verifies the generation pipeline is idempotent: runs it twice and fails if
# the second run changes any generated output, then reports whether the
# committed tree is in sync with the pipeline.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

checksum() {
    find "$ROOT/botapi" "$ROOT/Sources/TelegramBotAPI/Generated" \
        "$ROOT/Sources/TelegramBotKit/Generated" \
        -type f \( -name '*.swift' -o -name '*.json' -o -name '*.html' \) -print0 \
        | sort -z | xargs -0 shasum -a 256
}

snapshot_checksum() {
    shasum -a 256 "$ROOT/botapi/telegram-bot-api.html" "$ROOT/botapi/snapshot.json"
}

# Compare with the input to this run, not HEAD: adopting a new snapshot is a
# legitimate uncommitted change and must be verifiable before committing it.
INPUT="$(snapshot_checksum)"
"$ROOT/Scripts/generate-api.sh" >/dev/null
if [ "$INPUT" != "$(snapshot_checksum)" ]; then
    echo "verify-generated: generation modified the documentation snapshot or metadata" >&2
    exit 1
fi
FIRST="$(checksum)"
"$ROOT/Scripts/generate-api.sh" >/dev/null
SECOND="$(checksum)"

if [ "$INPUT" != "$(snapshot_checksum)" ]; then
    echo "verify-generated: generation modified the documentation snapshot or metadata" >&2
    exit 1
fi

if [ "$FIRST" != "$SECOND" ]; then
    echo "verify-generated: pipeline is not idempotent" >&2
    diff <(echo "$FIRST") <(echo "$SECOND") >&2 || true
    exit 1
fi

if ! git -C "$ROOT" diff --quiet -- \
    botapi Sources/TelegramBotAPI/Generated Sources/TelegramBotKit/Generated; then
    echo "verify-generated: pipeline idempotent, but generated sources differ from the last commit — remember to commit them"
else
    echo "verify-generated: OK"
fi
