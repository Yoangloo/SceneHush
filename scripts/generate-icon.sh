#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
xcrun swift "$PROJECT_ROOT/scripts/GenerateIcon.swift" "$PROJECT_ROOT/assets"
iconutil --convert icns "$PROJECT_ROOT/assets/SceneHush.iconset" \
  --output "$PROJECT_ROOT/assets/SceneHush.icns"
printf 'Generated assets/SceneHush.icns and PNG previews.\n'

