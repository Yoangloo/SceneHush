#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="1.2.5"
ARCHITECTURE="universal"
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch) ARCHITECTURE="${2:?Missing architecture}"; shift 2 ;;
    --version) APP_VERSION="${2:?Missing version}"; shift 2 ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    -h|--help)
      printf 'Usage: scripts/package.sh [--arch universal|arm64|x86_64] [--version 1.2.5] [--skip-build]\n'
      exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done
case "$ARCHITECTURE" in arm64|x86_64|universal) ;; *) printf 'Invalid architecture.\n' >&2; exit 2 ;; esac
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Version must have the form 1.0.0.\n' >&2
  exit 2
fi

if [[ "$SKIP_BUILD" == false ]]; then
  "$PROJECT_ROOT/scripts/build.sh" --arch "$ARCHITECTURE" --version "$APP_VERSION"
fi
APP_PATH="$PROJECT_ROOT/build/SceneHush.app"
if [[ ! -d "$APP_PATH" ]]; then printf 'Build SceneHush.app before packaging.\n' >&2; exit 1; fi

actual_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
if [[ "$actual_version" != "$APP_VERSION" ]]; then
  printf 'App version %s does not match requested version %s.\n' "$actual_version" "$APP_VERSION" >&2
  exit 1
fi
actual_architectures="$(xcrun lipo -archs "$APP_PATH/Contents/MacOS/SceneHush")"
case "$ARCHITECTURE" in
  universal)
    if [[ "$actual_architectures" != *arm64* || "$actual_architectures" != *x86_64* ]]; then
      printf 'Universal package requires both arm64 and x86_64 slices.\n' >&2; exit 1
    fi ;;
  *)
    if [[ "$actual_architectures" != "$ARCHITECTURE" ]]; then
      printf 'Built app architecture does not match requested package architecture.\n' >&2; exit 1
    fi ;;
esac
codesign --verify --strict "$APP_PATH"

DIST_PATH="$PROJECT_ROOT/dist"
mkdir -p "$DIST_PATH"
PACKAGE_NAME="SceneHush-$APP_VERSION-$ARCHITECTURE"
STAGING="$(mktemp -d "${TMPDIR:-/tmp}/SceneHush-package.XXXXXX")"
DMG_MOUNT=""
cleanup() {
  if [[ -n "$DMG_MOUNT" ]] && ! hdiutil detach "$DMG_MOUNT" >/dev/null; then
    printf 'Could not detach the temporary volume. Keeping its backing image in %s.\n' "$STAGING" >&2
    return
  fi
  rm -rf "$STAGING"
}
trap cleanup EXIT
DMG_STAGING="$STAGING/disk-image"
mkdir -p "$DMG_STAGING/.background"
python3 "$PROJECT_ROOT/scripts/installer/prepare.py" \
  --project-root "$PROJECT_ROOT" --output "$DMG_STAGING/Installation Guide.html" --version "$APP_VERSION"
ditto "$APP_PATH" "$DMG_STAGING/SceneHush.app"
ln -s /Applications "$DMG_STAGING/Applications"
cp "$PROJECT_ROOT/LICENSE" "$DMG_STAGING/.LICENSE.txt"
xcrun clang -fobjc-arc -Wno-deprecated-declarations -framework AppKit -framework CoreServices \
  "$PROJECT_ROOT/scripts/installer/dmg/VolumeAssets.m" -o "$STAGING/VolumeAssets"
"$STAGING/VolumeAssets" render "$DMG_STAGING/.background/background.png"

# Resolve the Finder background against its own volume, never the build checkout.
hdiutil create -volname "SceneHush $APP_VERSION" -srcfolder "$DMG_STAGING" \
  -fs HFS+ -ov -format UDRW "$STAGING/writable.dmg"
hdiutil attach -readwrite -nobrowse -noautoopen -plist "$STAGING/writable.dmg" > "$STAGING/attach.plist"
DMG_MOUNT="$(python3 -c 'import plistlib,sys; p=plistlib.load(open(sys.argv[1],"rb")); print(next(e["mount-point"] for e in p["system-entities"] if "mount-point" in e))' "$STAGING/attach.plist")"
"$STAGING/VolumeAssets" bookmark "$DMG_MOUNT" "$STAGING/background.book"
python3 "$PROJECT_ROOT/scripts/installer/dmg/generate_layout.py" "$DMG_MOUNT" "$STAGING/background-metadata.plist" \
  --native-bookmark "$STAGING/background.book"
"$STAGING/VolumeAssets" verify "$DMG_MOUNT" "$STAGING/background-metadata.plist"
hdiutil detach "$DMG_MOUNT"
DMG_MOUNT=""

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_PATH/$PACKAGE_NAME.zip"
hdiutil convert "$STAGING/writable.dmg" -format UDZO -ov -o "$DIST_PATH/$PACKAGE_NAME.dmg"
(
  cd "$DIST_PATH"
  shasum -a 256 "$PACKAGE_NAME.dmg" "$PACKAGE_NAME.zip" > "$PACKAGE_NAME-SHA256SUMS.txt"
)
printf '\nRelease assets:\n'
printf '  %s\n' "$DIST_PATH/$PACKAGE_NAME.dmg" "$DIST_PATH/$PACKAGE_NAME.zip" \
  "$DIST_PATH/$PACKAGE_NAME-SHA256SUMS.txt"

