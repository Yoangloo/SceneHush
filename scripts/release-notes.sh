#!/bin/bash
set -euo pipefail

APP_VERSION="${1:-1.0.1}"
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Version must have the form 1.0.0.\n' >&2
  exit 2
fi
printf '# SceneHush %s\n\n' "$APP_VERSION"
cat <<'MARKDOWN'
English · 简体中文 · 日本語

## English

A quiet corner for all your screens. Choose any corner of your Mac's displays
to dim every connected, supported screen to 0% through BetterDisplay. Move away
to restore each screen's previous brightness, or choose to restore on the next
corner entry. The menu and settings support English, Simplified Chinese, and Japanese.

The menu bar shows only an icon; open its menu to see the SceneHush name.

- Download the **universal DMG** or **ZIP** below for Apple Silicon and Intel Macs.
- Requires **macOS 13 or later** and a separately installed, running **BetterDisplay**
  with command-line integration enabled.
- This release is **ad-hoc signed, without Developer ID signing or Apple notarization**.
  If blocked, confirm the download source, then use **System Settings → Privacy & Security → Open Anyway**.
- SceneHush adjusts brightness; it does not lock macOS or guarantee that the display power is off.

## 简体中文

一个角落，让所有屏幕安静下来。任选屏幕四个角之一，通过 BetterDisplay
将所有已连接、受支持屏幕的亮度降到 0%。默认移开鼠标就恢复各屏原亮度，
也可设为再次进入角落时恢复。界面支持英语、简体中文和日语切换。

菜单栏只显示图标，点开菜单后可看到 SceneHush 名称。

- 下载下方 **universal DMG** 或 **ZIP**，同时支持 Apple Silicon 与 Intel Mac。
- 需要 **macOS 13 或更新版本**，并单独安装、运行 **BetterDisplay**，开启其命令行集成。
- 此版本使用**临时签名，尚无 Developer ID 签名和 Apple 公证**。如被系统拦截，
  请核对下载来源后，在「**系统设置 → 隐私与安全性 → 仍要打开**」中放行。
- SceneHush 调整亮度，不会锁定 macOS，也不保证关闭屏幕电源。

## 日本語

画面のすみから、静かなひとときへ。4 つのコーナーから 1 つを選び、
BetterDisplay を通じて接続中の対応ディスプレイをすべて明るさ 0% にします。
ポインタを離すと各画面の元の明るさに戻ります。次にコーナーへ入ったときに
戻す設定も選べます。表示言語は英語・簡体字中国語・日本語から選択できます。

メニューバーにはアイコンだけを表示し、メニューを開くと SceneHush の名前を確認できます。

- 下の **universal DMG** または **ZIP** は Apple Silicon と Intel Mac に対応しています。
- **macOS 13 以降**と、コマンドライン連携を有効にした **BetterDisplay** が別途必要です。
- このリリースは**アドホック署名で、Developer ID 署名および Apple の公証はありません**。
  ブロックされた場合は配布元を確認し、「**システム設定 → プライバシーとセキュリティ → このまま開く**」を選択してください。
- SceneHush は明るさを調整するアプリです。macOS のロックやディスプレイ電源の切断は行いません。

---

[Installation and source](https://github.com/Yoangloo/SceneHush) ·
[Changelog](https://github.com/Yoangloo/SceneHush/blob/main/CHANGELOG.md) ·
[BetterDisplay](https://github.com/waydabber/BetterDisplay)
MARKDOWN
