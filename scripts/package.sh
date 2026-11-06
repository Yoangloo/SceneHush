#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="1.2.4"
ARCHITECTURE="universal"
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch) ARCHITECTURE="${2:?Missing architecture}"; shift 2 ;;
    --version) APP_VERSION="${2:?Missing version}"; shift 2 ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    -h|--help)
      printf 'Usage: scripts/package.sh [--arch universal|arm64|x86_64] [--version 1.2.4] [--skip-build]\n'
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
trap 'rm -rf "$STAGING"' EXIT
INSTALLER_WORK="$STAGING/installer"
DMG_STAGING="$STAGING/disk-image"
mkdir -p "$INSTALLER_WORK/payload" "$INSTALLER_WORK/packages" "$DMG_STAGING"
python3 "$PROJECT_ROOT/scripts/installer/prepare.py" resources \
  --project-root "$PROJECT_ROOT" --work-dir "$INSTALLER_WORK" \
  --version "$APP_VERSION" --arch "$ARCHITECTURE"
ditto "$APP_PATH" "$INSTALLER_WORK/payload/SceneHush.app"

# A static app payload: no privileged install scripts, automatic launch or settings changes.
pkgbuild --root "$INSTALLER_WORK/payload" \
  --component-plist "$INSTALLER_WORK/components.plist" \
  --identifier io.github.yoangloo.SceneHush.pkg --version "$APP_VERSION" \
  --install-location /Applications "$INSTALLER_WORK/packages/SceneHush-component.pkg"
productbuild --synthesize --product "$INSTALLER_WORK/requirements.plist" \
  --package "$INSTALLER_WORK/packages/SceneHush-component.pkg" "$INSTALLER_WORK/Distribution.xml"
python3 "$PROJECT_ROOT/scripts/installer/prepare.py" distribution "$INSTALLER_WORK/Distribution.xml"
productbuild --distribution "$INSTALLER_WORK/Distribution.xml" \
  --resources "$INSTALLER_WORK/resources" --package-path "$INSTALLER_WORK/packages" \
  "$DIST_PATH/$PACKAGE_NAME.pkg"

cp "$DIST_PATH/$PACKAGE_NAME.pkg" "$DMG_STAGING/Install SceneHush.pkg"
cp "$INSTALLER_WORK/Installation Guide.html" "$DMG_STAGING/Installation Guide.html"
cp "$PROJECT_ROOT/LICENSE" "$DMG_STAGING/.LICENSE.txt"
cp "$PROJECT_ROOT/scripts/installer/dmg/Finder-layout.dsstore" "$DMG_STAGING/.DS_Store"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_PATH/$PACKAGE_NAME.zip"
hdiutil create -volname "SceneHush $APP_VERSION" -srcfolder "$DMG_STAGING" \
  -ov -format UDZO "$DIST_PATH/$PACKAGE_NAME.dmg"
(
  cd "$DIST_PATH"
  shasum -a 256 "$PACKAGE_NAME.pkg" "$PACKAGE_NAME.dmg" "$PACKAGE_NAME.zip" > "$PACKAGE_NAME-SHA256SUMS.txt"
)
printf '\nRelease assets:\n'
printf '  %s\n' "$DIST_PATH/$PACKAGE_NAME.pkg" "$DIST_PATH/$PACKAGE_NAME.dmg" "$DIST_PATH/$PACKAGE_NAME.zip" \
  "$DIST_PATH/$PACKAGE_NAME-SHA256SUMS.txt"

