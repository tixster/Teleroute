#!/usr/bin/env bash
# Regenerates the Telegram Bot API layers from the committed documentation
# snapshot in botapi/.
#
#   Scripts/generate-api.sh              generate from the committed snapshot
#   Scripts/generate-api.sh --refresh    re-download the documentation first
#
# The default run is offline and deterministic: the same snapshot always
# produces the same sources. Only --refresh touches the network, and it also
# rewrites botapi/snapshot.json so the new snapshot is adopted deliberately.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REFRESH=()

if [ "${1:-}" = "--refresh" ]; then
    curl --fail --silent --show-error --location \
        --output "$ROOT/botapi/telegram-bot-api.html" \
        https://core.telegram.org/bots/api
    REFRESH=(--refresh-snapshot)
fi

swift run --package-path "$ROOT/Tooling/BotAPIGen" -c release BotAPIGen \
    --snapshot "$ROOT/botapi" \
    --types-output "$ROOT/Sources/TelegramBotAPI/Generated" \
    --client-output "$ROOT/Sources/TelegramBotKit/Generated" \
    "${REFRESH[@]+"${REFRESH[@]}"}"
