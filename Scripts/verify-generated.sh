#!/usr/bin/env bash
# Verifies the generation pipeline is idempotent: runs it twice and fails if
# the second run changes any generated output, then reports whether the
# committed tree is in sync with the pipeline.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

checksum() {
    find "$ROOT/openapi" "$ROOT/Sources/TelegramBotAPI/Generated" \
        "$ROOT/Sources/TelegramBotKit/Generated" \
        -type f \( -name '*.swift' -o -name '*.json' \) -print0 \
        | sort -z | xargs -0 shasum -a 256
}

"$ROOT/Scripts/generate-api.sh" >/dev/null
FIRST="$(checksum)"
"$ROOT/Scripts/generate-api.sh" >/dev/null
SECOND="$(checksum)"

if [ "$FIRST" != "$SECOND" ]; then
    echo "verify-generated: pipeline is not idempotent" >&2
    diff <(echo "$FIRST") <(echo "$SECOND") >&2 || true
    exit 1
fi

if ! git -C "$ROOT" diff --quiet -- \
    openapi Sources/TelegramBotAPI Sources/TelegramBotKit/Generated; then
    echo "verify-generated: pipeline idempotent, but generated sources differ from the last commit — remember to commit them"
else
    echo "verify-generated: OK"
fi
