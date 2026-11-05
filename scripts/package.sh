#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="1.0.0"
ARCHITECTURE="universal"
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch) ARCHITECTURE="${2:?Missing architecture}"; shift 2 ;;
    --version) APP_VERSION="${2:?Missing version}"; shift 2 ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    -h|--help)
      printf 'Usage: scripts/package.sh [--arch universal|arm64|x86_64] [--version 1.0.0] [--skip-build]\n'
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
ditto "$APP_PATH" "$STAGING/SceneHush.app"
ln -s /Applications "$STAGING/Applications"
cp "$PROJECT_ROOT/LICENSE" "$STAGING/LICENSE.txt"
cat > "$STAGING/Install.txt" <<'INSTALL'
SceneHush — a quieter screen, one corner away.

1. Drag SceneHush.app to Applications.
2. Open SceneHush and choose your corner from the menu bar.
3. Install and run BetterDisplay to control display brightness.

English / 简体中文 / 日本語 can be selected in SceneHush settings.

This release is ad-hoc signed, not Apple-notarized. If macOS blocks the app,
open System Settings > Privacy & Security and use Open Anyway after checking
that the download came from https://github.com/Yoangloo/SceneHush/releases.

Getting started: https://github.com/Yoangloo/SceneHush

简体中文
1. 将 SceneHush.app 拖入 Applications（应用程序）文件夹后打开。
2. 安装并运行 BetterDisplay，在 SceneHush 菜单中选择触发角落。
3. 可在设置中切换界面语言。
此版本使用临时签名，尚未经过 Apple 公证。如被系统拦截，请核对下载来源，
再前往「系统设置 > 隐私与安全性」点击「仍要打开」。

日本語
1. SceneHush.app を Applications（アプリケーション）にドラッグして開きます。
2. BetterDisplay をインストールして起動し、SceneHush のメニューでコーナーを選びます。
3. 設定で表示言語を変更できます。
このバージョンはアドホック署名で、Apple の公証を受けていません。起動が
ブロックされた場合は配布元を確認し、「システム設定 > プライバシーと
セキュリティ」で「このまま開く」を選択してください。
INSTALL

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_PATH/$PACKAGE_NAME.zip"
hdiutil create -volname "SceneHush $APP_VERSION" -srcfolder "$STAGING" \
  -ov -format UDZO "$DIST_PATH/$PACKAGE_NAME.dmg"
(
  cd "$DIST_PATH"
  shasum -a 256 "$PACKAGE_NAME.dmg" "$PACKAGE_NAME.zip" > "$PACKAGE_NAME-SHA256SUMS.txt"
)
printf '\nRelease assets:\n'
printf '  %s\n' "$DIST_PATH/$PACKAGE_NAME.dmg" "$DIST_PATH/$PACKAGE_NAME.zip" \
  "$DIST_PATH/$PACKAGE_NAME-SHA256SUMS.txt"

