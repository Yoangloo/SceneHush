#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="1.2.2"
ARCHITECTURE="universal"
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch) ARCHITECTURE="${2:?Missing architecture}"; shift 2 ;;
    --version) APP_VERSION="${2:?Missing version}"; shift 2 ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    -h|--help)
      printf 'Usage: scripts/package.sh [--arch universal|arm64|x86_64] [--version 1.2.2] [--skip-build]\n'
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
SceneHush — screens at rest. Work in motion.

1. Drag SceneHush.app to Applications.
2. Open SceneHush and follow the introduction; no companion app is required.
3. Try or skip the five-second dark-to-light demonstration, then choose a corner.
   Escape restores immediately. Corner triggers are paused during the introduction.

No Accessibility, Screen Recording, or administrator permission is needed for
display control. Optional launch at login may need macOS Login Items approval.
SceneHush changes RGB display output without a desktop overlay or a hardware
brightness change. It does not pause agents, lock your Mac, prevent sleep,
or guarantee agent compatibility. HDR, virtual displays and some drivers
may be unsupported. Restore displays and quit an old release before upgrading.

English / 简体中文 / 日本語 can be selected in SceneHush settings.

This release is ad-hoc signed, not Apple-notarized. If macOS blocks the app,
open System Settings > Privacy & Security and use Open Anyway after checking
that the download came from https://github.com/Yoangloo/SceneHush/releases.

Getting started: https://github.com/Yoangloo/SceneHush

简体中文
1. 将 SceneHush.app 拖入 Applications（应用程序）文件夹后打开。
2. 按引导了解权限，可体验或跳过 5 秒暗屏渐亮演示，再选择触发角落。
3. 演示中按 Escape 立即恢复，引导期间暂停角落触发；设置中可切换语言。
显示控制无需辅助功能、屏幕录制或管理员授权，也无需配套 App。可选的登录
启动可能需要在 macOS 登录项中批准。此工具调暗 RGB 显示输出，不添加桌面
遮罩、不改变硬件亮度、不暂停 agent；不会锁屏或阻止休眠，也不保证每一种
agent 流程兼容。HDR、虚拟屏及部分驱动可能不支持。升级前先恢复显示并退出旧版。
此版本使用临时签名，尚未经过 Apple 公证。如被系统拦截，请核对下载来源，
再前往「系统设置 > 隐私与安全性」点击「仍要打开」。

日本語
1. SceneHush.app を Applications（アプリケーション）にドラッグして開きます。
2. ガイドで権限を確認し、5 秒間の暗転・復元デモを試すかスキップします。
3. Escape で即座に復元できます。ガイド中はコーナー操作を一時停止します。
追加アプリや、表示制御のためのアクセシビリティ・画面収録・管理者の権限は
不要です。任意のログイン時の起動は、macOS 側で承認が必要な場合があります。
RGB 出力を暗くし、デスクトップを覆ったり、ハードウェアの輝度を変えたり、
エージェントを一時停止したりしません。HDR、仮想画面、一部のドライバーは
非対応の場合があります。ロックやスリープ防止、エージェントとの互換性は
保証しません。更新前に画面を復元し、旧版を終了してください。
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

