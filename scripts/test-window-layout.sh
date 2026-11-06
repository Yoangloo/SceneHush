#!/bin/bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/SceneHush-window-layout.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
app_dir="$test_dir/WindowLayoutCheck.app"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Frameworks" "$app_dir/Contents/Resources"

# Only configuration types are linked. The display engine and app delegate are excluded.
{ printf 'import CoreGraphics\n'; cat "$project_dir/Sources/SceneHushCore/Configuration.swift"; } > "$test_dir/Configuration.swift"
xcrun swiftc -emit-library -emit-module -module-name SceneHushCore \
  "$test_dir/Configuration.swift" \
  -emit-module-path "$test_dir/SceneHushCore.swiftmodule" \
  -Xlinker -install_name -Xlinker '@rpath/libSceneHushCore.dylib' \
  -o "$app_dir/Contents/Frameworks/libSceneHushCore.dylib"
xcrun swiftc -parse-as-library -I "$test_dir" -L "$app_dir/Contents/Frameworks" -lSceneHushCore \
  -Xlinker -rpath -Xlinker '@executable_path/../Frameworks' \
  "$project_dir/Sources/SceneHush/SceneStyle.swift" \
  "$project_dir/Sources/SceneHush/SettingsWindow.swift" \
  "$project_dir/Sources/SceneHush/OnboardingWindow.swift" \
  "$project_dir/Sources/SceneHush/Localizer.swift" \
  "$project_dir/Tests/WindowLayout/WindowLayoutMain.swift" \
  -o "$app_dir/Contents/MacOS/WindowLayoutCheck"
cp "$project_dir/Sources/SceneHush/Resources/"*.json "$app_dir/Contents/Resources/"
cp "$project_dir/assets/SceneHush.icns" "$app_dir/Contents/Resources/"
cat > "$app_dir/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>io.github.yoangloo.SceneHush.WindowLayoutCheck</string>
  <key>CFBundleExecutable</key><string>WindowLayoutCheck</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSUIElement</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST
"$app_dir/Contents/MacOS/WindowLayoutCheck" "${1:-$test_dir/report.json}"
