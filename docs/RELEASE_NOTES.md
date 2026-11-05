# SceneHush 1.1.0

## English

**New in 1.1.0:** SceneHush now runs on its own. Native macOS display control is the default; BetterDisplay is an optional compatibility mode.

Move the pointer into a chosen corner to make connected, supported display output dark. By default, moving away restores the saved display state. The menu bar shows only an icon; open its menu to see the SceneHush name.

The project began with a MacBook and external monitor: one bottom-right-corner action to dim both through the BetterDisplay already installed. It grew into a small tool for short breaks while a computer agent has work in progress. This release removes the extra-app requirement for native mode, while keeping the current desktop session. Some desktop workflows can be interrupted by locking or sleeping; other agents continue independently. SceneHush does not prevent sleep or automatic locking, and does not guarantee continued agent execution.

- Native mode uses CoreGraphics gamma controls, with no desktop overlay and no BetterDisplay dependency.
- Choose any of the four corners, with restore on exit or on the next corner entry.
- Switch the menu and settings between English, Simplified Chinese, Japanese, and the system language.
- Use optional BetterDisplay mode for another display-control path. It requires BetterDisplay running with command-line integration enabled.
- Save display state locally before dimming and attempt restoration after a reported failure. A watchdog attempts recovery after an unexpected main-app exit in native mode only; it does not monitor BetterDisplay mode.
- Enable launch at login, pause the trigger, or restore from the menu. Recovery data stays on your Mac, without telemetry or background network requests.

**Display compatibility:** native mode darkens RGB display output. It does not set the hardware brightness slider to 0% or guarantee that the backlight or display power turns off. HDR, virtual displays, and some drivers may not support native control or may override it. A reported failure triggers a restoration attempt and an error; optional BetterDisplay mode is another choice for that setup. No desktop overlay is added, but screen-capture and agent behavior still need validation in your own environment.

**Install:** download the universal DMG or ZIP and move SceneHush.app into Applications. Requires macOS 13+ on Apple Silicon or Intel. Native mode needs no separate app.

**Signing:** this release is ad-hoc signed, without Developer ID signing or Apple notarization. If macOS blocks it, verify that you trust the release, then use System Settings → Privacy & Security → Open Anyway. Source build and checksum instructions are in the README.

**Not a lock screen:** SceneHush adds no authentication. Anyone nearby may restore the display and use the unlocked Mac. Use macOS Lock Screen in public or shared environments, or whenever the computer must be left securely unattended. A dark screen is not a privacy boundary.

## 简体中文

**1.1.0 更新：** SceneHush 现在可以独立运行。默认使用 macOS 原生显示控制，BetterDisplay 改为可选兼容模式。

把鼠标移到选定角落，让已连接且受支持屏幕的显示输出暗下来。默认移开鼠标后，恢复保存的显示状态。顶部菜单栏只显示图标，点开菜单后可看到 SceneHush 名称。

项目起于 MacBook 加外接屏的一个需求：通过右下角动作，用电脑上已有的 BetterDisplay 一起调暗两块屏幕。后来，它成为一个面向 agent 工作期间短暂离席的小工具。这一版让原生模式无需其他 App，同时保留当前桌面会话。一些桌面流程可能因锁屏或睡眠中断，另一些 agent 可以独立运行。SceneHush 不阻止休眠或自动锁屏，也不保证 agent 持续运行。

- 原生模式通过 CoreGraphics 伽马控制调暗显示输出，不添加桌面遮罩，也不依赖 BetterDisplay。
- 四个角任选，支持移开恢复或再次进入角落时恢复。
- 英语、简体中文、日语及跟随系统，即切即生效。
- 可选 BetterDisplay 模式提供另一种显示控制方式；仅该模式需要运行 BetterDisplay 并开启命令行集成。
- 调暗前在本机保存显示状态，在系统报告失败后尝试恢复。监护进程仅在原生模式下为主程序异常退出尝试恢复，不监护 BetterDisplay 模式。
- 支持登录启动、暂停和菜单内恢复。恢复数据只保存在本机，无遥测或后台网络请求。

**显示器兼容性：** 原生模式调暗 RGB 显示输出，不会将硬件亮度滑块设为 0%，也不保证背光关闭或屏幕断电。HDR、虚拟显示屏及部分驱动可能不支持原生控制，或会覆盖设置。系统报告失败后会尝试恢复并提示错误；可针对这套设备尝试可选的 BetterDisplay 模式。原生模式没有桌面遮罩，但截图和 agent 的实际表现仍需在自己的环境中验证。

**安装：** 下载通用版 DMG 或 ZIP，将 SceneHush.app 移到应用程序。需要 macOS 13+，支持 Apple Silicon 和 Intel；原生模式无需另装 App。

**签名状态：** 此版本使用 ad-hoc 签名，尚无 Developer ID 签名及 Apple 公证。如 macOS 阻止打开，请核对并确认信任该版本后，到系统设置 → 隐私与安全性 → 仍要打开。源码构建和校验说明见 README。

**并非锁屏：** SceneHush 没有身份验证，旁人仍可恢复显示并操作这台未锁定的 Mac。公共、共享环境或需要安全地无人看管电脑时，请使用 macOS 系统锁屏。暗屏不构成隐私边界。

## 日本語

**1.1.0 の変更点：** SceneHush が単独で動作するようになりました。macOS 標準の表示制御が既定となり、BetterDisplay は任意の互換モードになりました。

選んだ隅にポインタを移動すると、接続中の対応ディスプレイの出力が暗くなります。初期設定では、ポインタを離すと保存した表示状態に戻ります。メニューバーにはアイコンだけを表示し、開いたメニューに SceneHush の名前が表示されます。

MacBook と外部モニターを、右下の操作で既存の BetterDisplay を使ってまとめて暗くしたい、という要望から生まれました。その後、エージェントの作業中に短く離席するためのツールへと育ちました。このリリースでは、ネイティブモードを追加アプリなしで使い、現在のデスクトップセッションを維持できます。一部のデスクトップ操作はロックやスリープで中断されますが、独立して動作するエージェントもあります。SceneHush はスリープや自動ロックを防がず、エージェントの動作継続を保証しません。

- ネイティブモードは CoreGraphics のガンマ制御を使用し、デスクトップを覆うウインドウや BetterDisplay を必要としません。
- 四隅から選び、ポインタを離したとき、または次に隅へ入ったときに復元できます。
- 英語・簡体字中国語・日本語・システム言語をすぐに切り替えられます。
- 任意の BetterDisplay モードで、別の制御方式を選べます。このモードのみ、BetterDisplay の起動とコマンドライン連携が必要です。
- 調整前の表示状態を Mac 内に保存し、失敗の報告後に復元を試みます。異常終了時の復元用監視はネイティブモードのみで、BetterDisplay モードは対象外です。
- ログイン時の起動、一時停止、メニューからの復元に対応します。復元データは Mac 内のみで、テレメトリーやバックグラウンド通信はありません。

**ディスプレイの互換性：** ネイティブモードは RGB の表示出力を暗くします。ハードウェアの輝度スライダーを 0% に設定するものではなく、バックライト消灯や電源オフを保証しません。HDR、仮想ディスプレイ、一部のドライバーは制御に非対応の場合や、設定を上書きする場合があります。失敗が報告されると復元を試み、エラーを表示します。その環境では任意の BetterDisplay モードも選べます。デスクトップを覆うウインドウは追加しませんが、キャプチャーとエージェントの動作は利用環境で確認してください。

**インストール：** Universal 版 DMG または ZIP をダウンロードし、SceneHush.app をアプリケーションに移動してください。macOS 13+、Apple Silicon と Intel に対応します。ネイティブモードでは別のアプリは不要です。

**署名：** このリリースは ad-hoc 署名のみで、Developer ID 署名と Apple の公証はありません。macOS にブロックされた場合は、配布元とリリースを信頼できることを確認してから、システム設定 → プライバシーとセキュリティ → このまま開くを選択してください。ソースのビルドとチェックサムは README を参照してください。

**画面ロックではありません：** 認証機能はなく、他の人が画面を戻して、ロックされていない Mac を操作できます。公共・共有の場所や、安全のために無人のコンピューターを保護する必要がある場合は、macOS の画面ロックを使用してください。暗い画面はプライバシーを守る境界ではありません。
