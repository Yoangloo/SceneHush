#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="1.2.2"
ARCHITECTURE="universal"
CONFIGURATION="release"

usage() {
  cat <<'USAGE'
Usage: scripts/build.sh [--arch universal|arm64|x86_64] [--version 1.2.2]
                        [--configuration release|debug]

Builds build/SceneHush.app with the installed Xcode command line tools.
CODE_SIGN_IDENTITY may name a Developer ID identity; the default is ad-hoc signing.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch) ARCHITECTURE="${2:?Missing architecture}"; shift 2 ;;
    --version) APP_VERSION="${2:?Missing version}"; shift 2 ;;
    --configuration) CONFIGURATION="${2:?Missing configuration}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$ARCHITECTURE" in
  arm64|x86_64) ARCHITECTURES=("$ARCHITECTURE") ;;
  universal) ARCHITECTURES=(arm64 x86_64) ;;
  *) printf 'Unsupported architecture: %s\n' "$ARCHITECTURE" >&2; exit 2 ;;
esac
case "$CONFIGURATION" in release|debug) ;; *) printf 'Invalid configuration.\n' >&2; exit 2 ;; esac
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Version must have the form 1.0.0.\n' >&2
  exit 2
fi
if [[ "$(uname -s)" != Darwin ]]; then
  printf 'SceneHush requires macOS and Xcode command line tools.\n' >&2
  exit 1
fi
if [[ ! -f "$PROJECT_ROOT/Package.swift" ]]; then
  printf 'Package.swift is missing from %s\n' "$PROJECT_ROOT" >&2
  exit 1
fi

if [[ ! -f "$PROJECT_ROOT/assets/SceneHush.icns" ]]; then
  "$PROJECT_ROOT/scripts/generate-icon.sh"
fi

BINARIES=()
RESOURCE_DIRECTORY=""
for architecture in "${ARCHITECTURES[@]}"; do
  BUILD_ARGUMENTS=(
    --package-path "$PROJECT_ROOT"
    --scratch-path "$PROJECT_ROOT/.build/$architecture"
    --configuration "$CONFIGURATION"
    --triple "$architecture-apple-macosx13.0"
    --product SceneHush
  )
  printf 'Building SceneHush %s (%s)…\n' "$APP_VERSION" "$architecture"
  MACOSX_DEPLOYMENT_TARGET=13.0 xcrun swift build "${BUILD_ARGUMENTS[@]}"
  binary_directory="$(MACOSX_DEPLOYMENT_TARGET=13.0 xcrun swift build "${BUILD_ARGUMENTS[@]}" --show-bin-path)"
  if [[ ! -x "$binary_directory/SceneHush" ]]; then
    printf 'Expected executable was not built: %s/SceneHush\n' "$binary_directory" >&2
    exit 1
  fi
  BINARIES+=("$binary_directory/SceneHush")
  if [[ -z "$RESOURCE_DIRECTORY" ]]; then RESOURCE_DIRECTORY="$binary_directory"; fi
done

APP_PATH="$PROJECT_ROOT/build/SceneHush.app"
APP_STAGING="$PROJECT_ROOT/build/.SceneHush-staging.app"
rm -rf "$APP_STAGING"
mkdir -p "$APP_STAGING/Contents/MacOS" "$APP_STAGING/Contents/Resources"

if [[ ${#BINARIES[@]} -eq 2 ]]; then
  xcrun lipo -create "${BINARIES[@]}" -output "$APP_STAGING/Contents/MacOS/SceneHush"
else
  cp "${BINARIES[0]}" "$APP_STAGING/Contents/MacOS/SceneHush"
fi
chmod 755 "$APP_STAGING/Contents/MacOS/SceneHush"
cp "$PROJECT_ROOT/assets/SceneHush.icns" "$APP_STAGING/Contents/Resources/SceneHush.icns"
cp "$PROJECT_ROOT/LICENSE" "$APP_STAGING/Contents/Resources/LICENSE"

# SwiftPM's development bundle lookup is not the installed app's resource path.
# The app localizer loads these bundles from Bundle.main.resourceURL first.
shopt -s nullglob
for resource_bundle in "$RESOURCE_DIRECTORY"/*.bundle; do
  ditto "$resource_bundle" "$APP_STAGING/Contents/Resources/$(basename "$resource_bundle")"
done
shopt -u nullglob

cat > "$APP_STAGING/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>io.github.yoangloo.SceneHush</string>
  <key>CFBundleName</key><string>SceneHush</string>
  <key>CFBundleDisplayName</key><string>SceneHush</string>
  <key>CFBundleExecutable</key><string>SceneHush</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleVersion</key><string>$APP_VERSION</string>
  <key>CFBundleShortVersionString</key><string>$APP_VERSION</string>
  <key>CFBundleIconFile</key><string>SceneHush</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key><array><string>en</string><string>zh-Hans</string><string>ja</string></array>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Yoangloo</string>
</dict></plist>
PLIST

plutil -lint "$APP_STAGING/Contents/Info.plist"
SIGNING_IDENTITY="${CODE_SIGN_IDENTITY:--}"
if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  codesign --force --sign - "$APP_STAGING"
else
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_STAGING"
fi
codesign --verify --strict "$APP_STAGING"
rm -rf "$APP_PATH"
mv "$APP_STAGING" "$APP_PATH"
printf '\nBuilt: %s\n' "$APP_PATH"
xcrun lipo -archs "$APP_PATH/Contents/MacOS/SceneHush"

