# SceneHush 1.0.1

## English

**New in 1.0.1:** the menu bar now shows only an icon; click it to see the SceneHush name in the opened menu.

Move the pointer into a corner and let every supported display go quiet. SceneHush lives in the macOS menu bar and uses BetterDisplay to lower the brightness of your MacBook and external displays to 0%. By default, move away to restore each screen's previous brightness.

It began as a bottom-right-corner action for a MacBook and external monitor. The goal is a short break while a computer agent has work in progress: dim the screens while keeping the existing desktop session. Some desktop-interaction workflows can be interrupted by locking or sleeping; other agents are unaffected. SceneHush does not keep the Mac awake or guarantee continued agent execution.

- Choose any of the four corners.
- Restore on exit or on the next corner entry.
- Switch instantly between English, Simplified Chinese, Japanese, and the system language.
- Enable launch at login, pause the trigger, or restore brightness from the menu.
- Keep brightness recovery data on your Mac, with no telemetry or background network requests.
- Optionally replace a conflicting macOS Hot Corner, with a backup and explicit restoration.

**Install:** download the DMG or ZIP, then move SceneHush.app into Applications. Requires macOS 13+ and a separately installed, running BetterDisplay with command-line integration enabled. The app is universal for Apple Silicon and Intel.

**Signing:** this release is ad-hoc signed, without Developer ID signing or Apple notarization. If macOS blocks it, verify that you trust the release, then use System Settings → Privacy & Security → Open Anyway. See the README for build instructions and download verification.

SceneHush adjusts brightness; it does not lock macOS or add authentication. Anyone with access can restore brightness and operate the unlocked Mac. Use system locking in public, shared, or securely unattended situations. A 0% brightness value does not guarantee physical backlight or power-off and is not a privacy boundary.

## 简体中文

**1.0.1 更新：**菜单栏现在仅显示图标；点击展开菜单后，才显示 SceneHush 名称。

把鼠标移到角落，让所有受支持的屏幕一起安静下来。SceneHush 常驻 macOS 顶部菜单栏，通过 BetterDisplay 将 MacBook 内置屏和外接屏亮度降到 0%。默认移开鼠标后，各屏恢复各自原来的亮度。

它起于 MacBook 加外接屏的右下角调暗需求，面向电脑上的 agent 正在工作、人想短暂离开的场景：让屏幕暗下来，同时保留当前桌面会话。一些桌面交互流程可能因锁屏或睡眠而中断，另一些 agent 不受影响。SceneHush 不会防止睡眠，也不保证 agent 持续运行。

- 四个角任选。
- 支持移开后恢复，或再次进入角落时恢复。
- 英语、简体中文、日语及跟随系统，即切即生效。
- 支持登录自动启动，也可在菜单中暂停或立即恢复亮度。
- 恢复数据只保存在本机，无遥测和后台网络请求。
- 可选替换有冲突的 macOS 快捷角，并备份和手动还原。

**安装：**下载 DMG 或 ZIP，将 SceneHush.app 移到应用程序。需要 macOS 13+，并另行安装、运行 BetterDisplay，开启其命令行集成。通用版本同时支持 Apple Silicon 和 Intel。

**签名状态：**本版本为 ad-hoc 签名，尚无 Developer ID 签名及 Apple 公证。如果 macOS 阻止打开，请先确认信任该版本，再到系统设置 → 隐私与安全性 → 仍要打开。源码构建和文件校验说明见 README。

SceneHush 调整亮度，不会锁定 macOS，也没有身份验证。旁人可以恢复亮度并操作这台未锁定的 Mac。公共、共享环境或需要安全地无人看管电脑时，应使用系统锁屏。0% 不保证屏幕背光关闭或断电，也不构成隐私边界。

## 日本語

**1.0.1 の変更点：**メニューバーはアイコンのみになりました。クリックしてメニューを開くと、SceneHush の名前が表示されます。

ポインタを隅へ移動して、対応する画面すべてを静かに。SceneHush は macOS のメニューバーで動作し、BetterDisplay を通じて MacBook の内蔵画面と外部ディスプレイの明るさを 0% にします。初期設定では、ポインタを離すと各画面が元の明るさに戻ります。

MacBook と外部モニターを右下の操作でまとめて暗くしたい、という要望から生まれました。エージェントの作業中に少し離席するとき、現在のデスクトップセッションを保ちながら画面を暗くするためのツールです。一部のデスクトップ操作はロックやスリープで中断されますが、影響を受けないエージェントもあります。SceneHush はスリープ防止や、エージェントの継続動作を保証するものではありません。

- 四隅からトリガーを選択できます。
- ポインタを離すか、次に隅へ移動したときに明るさを復元できます。
- 英語・簡体字中国語・日本語・システム言語をすぐに切り替えられます。
- ログイン時の自動起動、一時停止、メニューからの即時復元に対応します。
- 復元データは Mac 内だけに保存し、テレメトリーやバックグラウンド通信は行いません。
- 競合する macOS ホットコーナーを任意で置き換え、元の設定を保存して復元できます。

**インストール：**DMG または ZIP をダウンロードし、SceneHush.app をアプリケーションに移動してください。macOS 13+ と、コマンドライン連携が有効な BetterDisplay の別途インストール・起動が必要です。Apple Silicon と Intel に対応する Universal アプリです。

**署名：**このリリースは ad-hoc 署名のみで、Developer ID 署名と Apple の公証はありません。macOS によってブロックされた場合は、信頼できるリリースであることを確認し、システム設定 → プライバシーとセキュリティ → このまま開くを使用してください。ソースからのビルドとファイル確認については README を参照してください。

SceneHush は明るさを調整するアプリであり、macOS のロックや認証は行いません。他の人が明るさを戻して、ロックされていない Mac を操作できます。公共・共有の場所や、安全に無人で管理する必要がある場合は、システムの画面ロックを使用してください。0% はバックライト消灯や電源オフを保証するものではなく、プライバシーを守る境界でもありません。
