# SceneHush 1.2.0

## English

**Native, from the first hello.** SceneHush now uses macOS display control only. BetterDisplay integration and the dimming-method selector have been removed.

This release makes the first run a short, understandable experience: learn what SceneHush changes, see which permissions it needs, then try an optional five-second demonstration. Your connected, supported screens go dark and slowly return to their saved appearance. Press Escape to restore immediately, or skip the demonstration. Corner triggers stay paused while the introduction is open. Finish to enter settings, and replay the introduction whenever you want.

**Only the display output changes. SceneHush does not pause your agents.** It leaves the desktop session in place, without a black overlay or a logout. This is for a short break when leaving that session unlocked is acceptable. It does not prevent sleep or automatic locking, guarantee agent compatibility, or ensure task completion.

- No Accessibility, Screen Recording, or administrator permission is needed for display control and corner detection. Optional launch at login may require approval in macOS Login Items.
- A new day/night switch icon, centered name and slogan, aligned settings, a subtle background, and Liquid Glass controls on macOS 26+. Earlier systems use native fallback controls.
- Four corner choices, restore on exit or next entry, menu bar icon only, and immediate English / 简体中文 / 日本語 switching remain available.
- Display state stays on your Mac. A recovery watchdog attempts restoration after an unexpected exit, including during the demonstration. No telemetry or background network requests.
- Existing corner, restoration, and language choices are retained. Restore displays and quit an older release before upgrading. Old external-app brightness files are preserved; if one is still pending, use the previous release to restore it before dimming with this version.

**Compatibility:** requires macOS 13+, Apple Silicon or Intel, and compatible display gamma control. RGB output becomes dark; the hardware brightness slider, backlight, and display power are not switched off. HDR, virtual displays, or some drivers may not support the control or may override it. Validate your actual capture and agent workflow.

**Install:** download the universal DMG or ZIP and move SceneHush.app into Applications. This release is ad-hoc signed, without Developer ID signing or Apple notarization. If macOS blocks it, verify the release source and use System Settings → Privacy & Security → Open Anyway only after confirming trust.

**Not a lock screen:** there is no authentication. Anyone nearby may restore the display and use the unlocked Mac. Use macOS Lock Screen when the computer must be left securely unattended.

## 简体中文

**从第一次打开，就是纯原生。** SceneHush 现在只使用 macOS 显示控制，已移除 BetterDisplay 集成及调暗方式选项。

首次使用变得更直观：先了解显示会发生什么变化、需要哪些权限，再选择体验 5 秒演示。已连接且受支持的屏幕会变黑，然后缓慢恢复到原来的显示状态。按 Escape 可立即恢复，也可以跳过演示。引导打开时暂停角落触发，完成后进入设置，之后随时可以重看。

**改变的只是显示输出，SceneHush 不会暂停你的 agent。** 它保留当前桌面会话，不添加黑色遮罩，也不退出登录，适合可以接受会话未锁定时的短暂离席。它不会阻止休眠或自动锁屏，不保证 agent 兼容性或任务完成。

- 显示控制和角落检测无需辅助功能、屏幕录制或管理员授权；可选的登录自动启动可能需要在 macOS“登录项”批准。
- 新日夜开关图标、居中的名称与 slogan、对齐的设置、轻微底纹；macOS 26+ 使用液态玻璃控件，较早系统使用原生兼容控件。
- 保留四角选择、移开或再次进入恢复、菜单栏仅图标，以及 English / 简体中文 / 日本語 即时切换。
- 显示状态仅保存在本机，监护进程在主程序异常退出时尝试恢复，也覆盖引导演示。无遥测或后台网络请求。
- 原有角落、恢复方式和语言偏好会保留。升级前先恢复显示并退出旧版；旧外部 App 亮度文件不会删除。如仍有待恢复的旧文件，请先用旧版恢复，再使用此版本调暗。

**兼容性：** 需要 macOS 13+、Apple Silicon 或 Intel，以及兼容的显示伽马控制。调暗的是 RGB 显示输出，不会把硬件亮度滑块设为 0%、关闭背光或让屏幕断电。HDR、虚拟屏及部分驱动可能不支持或会覆盖设置；请在自己的截图及 agent 流程中验证。

**安装：** 下载通用版 DMG 或 ZIP，将 SceneHush.app 移到应用程序。此版本使用 ad-hoc 签名，尚无 Developer ID 签名及 Apple 公证。如 macOS 阻止打开，请核对并确认信任发布来源后，到系统设置 → 隐私与安全性 → 仍要打开。

**不是锁屏：** 没有身份验证，旁人仍可恢复显示并操作未锁定的 Mac。需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 日本語

**最初の起動から、macOS 標準だけで。** SceneHush は標準の表示制御専用になり、BetterDisplay 連携と調光方式の選択を削除しました。

初回ガイドでは、表示の変化と必要な権限を確認し、任意で 5 秒間のデモを体験できます。接続中の対応画面が暗くなり、ゆっくりと保存した表示状態へ戻ります。Escape で直ちに復元でき、デモをスキップすることもできます。ガイド中はコーナー操作を一時停止し、完了すると設定が開きます。後から再表示も可能です。

**変わるのは画面出力だけです。SceneHush はエージェントを一時停止しません。** 黒いウインドウやログアウトを使わず、現在のデスクトップセッションを維持します。ロックしない状態を許容できる、短い離席のための機能です。スリープや自動ロックを防がず、エージェントとの互換性やタスクの完了を保証しません。

- 表示制御とコーナー検出にアクセシビリティ、画面収録、管理者の権限は不要です。任意のログイン時の起動には、macOS のログイン項目で承認が必要な場合があります。
- 新しい昼夜スイッチのアイコン、中央揃えの名前とスローガン、整列した設定、控えめな背景。macOS 26+ は Liquid Glass、以前のシステムは標準の互換コントロールを使います。
- 四隅の選択、離れたとき・次の操作時の復元、アイコンだけのメニューバー、English / 简体中文 / 日本語の即時切り替えを維持します。
- 表示状態は Mac 内に保存します。監視プロセスはデモ中を含む異常終了時に復元を試みます。テレメトリーやバックグラウンド通信はありません。
- 隅、復元方法、言語の設定は引き継ぎます。更新前に画面を復元して旧版を終了してください。外部アプリ用の古い輝度ファイルは削除せず、未復元のファイルがある場合は旧版で復元してから新版で調整してください。

**互換性：** macOS 13+、Apple Silicon または Intel と、対応するガンマ制御が必要です。RGB 出力を暗くしますが、ハードウェアの輝度、バックライト、電源はオフにしません。HDR、仮想画面、一部のドライバーは非対応や設定上書きの場合があります。実際のキャプチャーとエージェントの動作を利用環境で確認してください。

**インストール：** Universal 版 DMG または ZIP をダウンロードし、SceneHush.app をアプリケーションへ移動します。このリリースは ad-hoc 署名で、Developer ID 署名や Apple の公証はありません。macOS にブロックされた場合は、配布元を信頼できることを確認してから、システム設定 → プライバシーとセキュリティ → このまま開くを選択してください。

**画面ロックではありません：** 認証機能はなく、他の人が画面を戻して、ロックされていない Mac を操作できます。無人のコンピューターを安全に保護する必要がある場合は、macOS の画面ロックを使ってください。
