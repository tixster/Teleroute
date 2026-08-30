#!/usr/bin/env bash
# Regenerates Sources/TelegramBotAPI/Generated from the committed OpenAPI spec.
# The generator is pinned in Tooling/APIGen/Package.resolved; bump the `exact`
# version in Tooling/APIGen/Package.swift to upgrade it deliberately.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 "$ROOT/Scripts/patch-openapi.py" \
    "$ROOT/openapi/telegram-bot-api.json" \
    "$ROOT/openapi/telegram-bot-api.patched.json"

swift run --package-path "$ROOT/Tooling/APIGen" -c release \
    swift-openapi-generator generate \
    "$ROOT/openapi/telegram-bot-api.patched.json" \
    --config "$ROOT/openapi/openapi-generator-config.yaml" \
    --output-directory "$ROOT/Sources/TelegramBotAPI/Generated"
