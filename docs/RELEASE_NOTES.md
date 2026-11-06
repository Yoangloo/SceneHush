# SceneHush 1.2.4

## English

**Screens at rest. Local agents at work.** SceneHush darkens supported displays during a short break while leaving your apps and current desktop session in place.

Each README now presents three separate rows: language navigation, the main PKG download button, then ZIP, DMG, and all-release links. English, Simplified Chinese, and Japanese use the same order.

The new PKG opens the standard macOS Installer to install SceneHush into Applications. The optional DMG includes the PKG and an installation guide; the ZIP remains available for manual installation. [Installation help](https://github.com/Yoangloo/SceneHush/blob/v1.2.4/docs/INSTALL.md#english) explains Gatekeeper approval separately from installation authentication and the app's runtime permissions.

Display-restoration feedback now uses a simple green check and gray text, with no capsule background.

SceneHush continues to use native macOS display control, with no companion app. Your corner, restore behavior, language, and introduction preferences are retained. Restore displays and quit an older release before updating.

**Compatibility and installation:** macOS 13+, Apple Silicon or Intel, and compatible display gamma control are required. Open the universal PKG and follow the system Installer, which may request administrator authentication. Display control itself needs no administrator permission. This release has no Developer ID signing or Apple notarization; using a PKG does not remove Gatekeeper checks. If blocked, confirm the release source and your trust before using System Settings → Privacy & Security → Open Anyway, then confirm Open. The installer and installed app may each need this approval.

The app darkens RGB output; it does not set the hardware brightness slider to zero or turn off the backlight. HDR, virtual displays, and some drivers may be unsupported.

**Dimming is not locking.** Anyone nearby can restore the display and use the unlocked Mac. SceneHush does not pause agents, prevent sleep or automatic locking, or guarantee task completion. Use macOS Lock Screen when the computer must be left securely unattended.

## 简体中文

**屏幕歇一会，本地 agent 继续工作。** SceneHush 为短暂离席调暗受支持屏幕，保留 App 与当前桌面会话。

三语 README 下载区统一为三行：语言切换、PKG 主下载按钮、ZIP / DMG / 所有版本入口，顺序一致、各自独占一行。

新增 PKG，通过 macOS 系统安装器安装至应用程序；备选 DMG 内含 PKG 与安装指引，ZIP 保留手动安装方式。[安装帮助](https://github.com/Yoangloo/SceneHush/blob/v1.2.4/docs/INSTALL.md#简体中文)区分 Gatekeeper 允许步骤、安装认证和 App 运行权限。

恢复显示后的反馈改为绿色勾号配灰色文字，去掉胶囊背景。

SceneHush 仍使用 macOS 原生显示控制，无需配套 App。原有角落、恢复方式、语言和引导偏好会保留。升级前请先恢复显示并退出旧版。

**兼容性与安装：** 需要 macOS 13+、Apple Silicon 或 Intel，以及兼容的显示伽马控制。打开通用版 PKG，按系统安装器提示操作，过程中可能要求管理员认证；显示控制本身无需管理员权限。此版本尚无 Developer ID 签名及 Apple 公证，PKG 不会消除 Gatekeeper 检查。如被拦截，请先核对并确认信任发布来源，再到系统设置 → 隐私与安全性 → 仍要打开，并再次确认打开；安装包和安装后的 App 可能各需允许一次。

调暗的是 RGB 显示输出，不会把硬件亮度滑块设为 0% 或关闭背光；HDR、虚拟屏及部分驱动可能不支持。

**暗屏不等于锁屏。** 旁人仍可恢复显示并操作未锁定的 Mac。SceneHush 不会暂停 agent、阻止休眠或自动锁屏，也不保证任务完成。需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 日本語

**画面はひと休み。ローカルエージェントは作業中。** SceneHush は短い離席時に対応画面を暗くし、アプリと現在のデスクトップセッションをそのまま保ちます。

各 README のダウンロード欄を、言語の切り替え、PKG のメインダウンロードボタン、ZIP・DMG・すべてのリリースへのリンクの順に、それぞれ独立した行に配置しました。英語・簡体字中国語・日本語で共通の構成です。

新しい PKG は macOS 標準のインストーラを使ってアプリケーションに配置します。DMG には PKG とインストールガイドを含み、手動で配置するための ZIP も残しています。[インストールガイド](https://github.com/Yoangloo/SceneHush/blob/v1.2.4/docs/INSTALL.md#日本語)では、Gatekeeper の許可操作とインストール時の認証、アプリの実行権限を区別して説明します。

表示を復元した後のメッセージは、カプセル背景をなくし、緑のチェックとグレーの文字で表示します。

SceneHush は引き続き macOS 標準の表示制御を使い、追加アプリは不要です。コーナー、復元方法、言語、ガイドの設定は引き継ぎます。更新前に画面を復元して旧版を終了してください。

**互換性とインストール：** macOS 13+、Apple Silicon または Intel、および対応するガンマ制御が必要です。Universal 版 PKG を開き、システムのインストーラに従います。管理者認証が必要になる場合がありますが、表示制御そのものには不要です。このリリースには Developer ID 署名と Apple の公証がなく、PKG でも Gatekeeper の確認は必要です。ブロックされた場合は配布元を信頼できることを確認し、システム設定 → プライバシーとセキュリティ → このまま開くを選び、続けて「開く」を確認してください。インストーラとインストール後のアプリで、それぞれ許可が必要になる場合があります。

暗くするのは RGB 出力であり、ハードウェアの輝度をゼロにしたりバックライトを消したりしません。HDR、仮想画面、一部のドライバーは非対応の場合があります。

**暗転は画面ロックではありません。** 他の人が画面を戻して、ロックされていない Mac を操作できます。SceneHush はエージェントを一時停止せず、スリープや自動ロックを防がず、タスクの完了も保証しません。無人の Mac を安全に保護する必要がある場合は、macOS の画面ロックを使ってください。
