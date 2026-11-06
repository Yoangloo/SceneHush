# SceneHush 1.2.2

## English

SceneHush now uses a small sun in the menu bar. Introduction replay stays on the settings page and has been removed from the menu's action list.

The introduction has simpler actions: **Get started**, then **Try it**. **Skip** is at the top left, with Back available after the welcome step. The bottom left shows the app version, and the language selector stays at the bottom right. English, Simplified Chinese, and Japanese follow the same layout.

Window sizing stays under AppKit control to prevent content measurements from moving or resizing the window during display changes. Introduction transitions animate the content only.

SceneHush continues to use native macOS display control, with no companion app. Your corner, restore behavior, language, and introduction preferences are retained. Restore displays and quit an older release before updating.

**Compatibility and installation:** macOS 13+, Apple Silicon or Intel, and compatible display gamma control are required. Download the universal DMG or ZIP and move SceneHush.app into Applications. The app darkens RGB output; it does not set the hardware brightness slider to zero or turn off the backlight. HDR, virtual displays, and some drivers may be unsupported. This release is ad-hoc signed and not Apple-notarized. If blocked, confirm the release source and your trust before using System Settings → Privacy & Security → Open Anyway.

**Dimming is not locking.** Anyone nearby can restore the display and use the unlocked Mac. SceneHush does not pause agents, prevent sleep or automatic locking, or guarantee task completion. Use macOS Lock Screen when the computer must be left securely unattended.

## 简体中文

菜单栏图标改为小太阳。引导入口保留在设置页，已从顶部菜单的操作列表中移除。

引导按钮改得更直接：先「**开始**」，再「**试试**」。「**跳过**」移到左上角，进入下一步后可从同一区域返回。左下角显示 App 版本，语言选择保留在右下角。英中日三语沿用相同布局。

窗口尺寸交由 AppKit 管理，避免切换显示屏时内容尺寸测量引起窗口移动或缩放；引导只对内容切换应用动画。

SceneHush 仍使用 macOS 原生显示控制，无需配套 App。原有角落、恢复方式、语言和引导偏好会保留。升级前请先恢复显示并退出旧版。

**兼容性与安装：** 需要 macOS 13+、Apple Silicon 或 Intel，以及兼容的显示伽马控制。下载通用版 DMG 或 ZIP，将 SceneHush.app 移到应用程序。调暗的是 RGB 显示输出，不会把硬件亮度滑块设为 0% 或关闭背光；HDR、虚拟屏及部分驱动可能不支持。此版本使用 ad-hoc 签名，尚未经过 Apple 公证。如被拦截，请先核对并确认信任发布来源，再到系统设置 → 隐私与安全性 → 仍要打开。

**暗屏不等于锁屏。** 旁人仍可恢复显示并操作未锁定的 Mac。SceneHush 不会暂停 agent、阻止休眠或自动锁屏，也不保证任务完成。需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 日本語

メニューバーのアイコンを小さな太陽に変更しました。ガイドの再表示は設定画面に残し、メニューの操作一覧からは削除しました。

ガイドのボタンは「**はじめる**」、次に「**試してみる**」へと簡潔にしました。「**スキップ**」は左上に移動し、次のステップでは同じナビゲーション領域から戻れます。左下にはアプリのバージョン、右下には言語選択を表示します。英語・簡体字中国語・日本語で同じレイアウトを使います。

ウインドウのサイズは AppKit で管理し、画面の切り替え時にコンテンツの計測で位置やサイズが変わることを防ぎます。ガイドのアニメーションはコンテンツの切り替えだけに適用します。

SceneHush は引き続き macOS 標準の表示制御を使い、追加アプリは不要です。コーナー、復元方法、言語、ガイドの設定は引き継ぎます。更新前に画面を復元して旧版を終了してください。

**互換性とインストール：** macOS 13+、Apple Silicon または Intel、および対応するガンマ制御が必要です。Universal 版 DMG または ZIP をダウンロードし、SceneHush.app をアプリケーションへ移動します。暗くするのは RGB 出力であり、ハードウェアの輝度をゼロにしたりバックライトを消したりしません。HDR、仮想画面、一部のドライバーは非対応の場合があります。このリリースは ad-hoc 署名で、Apple の公証はありません。起動がブロックされた場合は、配布元を信頼できることを確認してから、システム設定 → プライバシーとセキュリティ → このまま開くを選択してください。

**暗転は画面ロックではありません。** 他の人が画面を戻して、ロックされていない Mac を操作できます。SceneHush はエージェントを一時停止せず、スリープや自動ロックを防がず、タスクの完了も保証しません。無人の Mac を安全に保護する必要がある場合は、macOS の画面ロックを使ってください。
