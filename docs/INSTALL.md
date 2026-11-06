# Install SceneHush

[English](#english) · [简体中文](#简体中文) · [日本語](#日本語)

## English

### Drag the app into Applications

1. Download **SceneHush-1.2.5-universal.dmg** from [Yoangloo/SceneHush Releases](https://github.com/Yoangloo/SceneHush/releases/latest).
2. If you are updating, restore displays and quit the older SceneHush first.
3. Open the DMG. Its installation guidance shows you how to drag **SceneHush.app** into **Applications** and allow the app if macOS blocks it.
4. Drag **SceneHush.app** to **Applications**, then open it from Applications. Complete or skip the introduction to reach settings.

Requires macOS 13 or later, on Apple Silicon or Intel. Opening the DMG does not execute SceneHush, change Gatekeeper settings, or automatically remove quarantine. For the ZIP alternative, extract it and drag SceneHush.app into Applications.

### If macOS blocks the app

This release has no Developer ID signing or Apple notarization. The installation guidance explains approval in advance; it cannot remove Gatekeeper warnings. Continue only if you trust the repository and downloaded release.

1. Open **SceneHush** from Applications. If macOS says Apple cannot verify it, choose **Done** to close the alert; do not move it to the Trash.
2. Open **System Settings → Privacy & Security**, then scroll to **Security**.
3. Find the notice about the blocked file and choose **Open Anyway**. This option may appear only after an opening attempt.
4. Confirm **Open** in the next prompt and authenticate if macOS asks. SceneHush then opens its introduction.

See Apple's [Safely open apps on your Mac](https://support.apple.com/en-us/102445) for the official process. A managed Mac may restrict this option through your organization's IT policy. SceneHush does not change Gatekeeper settings or automatically remove quarantine.

Running SceneHush's display control and corner detection requires no administrator, Accessibility, or Screen Recording permission.

### First launch

The first launch after installing, reinstalling, or updating opens the introduction, even when older setup preferences exist. After you complete or skip it, ordinary relaunches of that installation do not repeat it. Your corner, restore behavior, language, and enabled-state preferences are retained. Open the installed copy from Applications.

Choose **Get started**, read the permission explanation, then choose **Try it** for the optional five-second dark-to-light demonstration. **Skip** is at the top right; the back arrow is at the top left. Your first supported macOS preferred language is used initially, and manual language choices are saved.

**Dimming is not locking.** SceneHush leaves the desktop session in place, does not keep the Mac awake, and does not guarantee continued agent execution. Use macOS Lock Screen when the Mac needs to be securely unattended.

## 简体中文

### 拖入应用程序

1. 从 [Yoangloo/SceneHush Releases](https://github.com/Yoangloo/SceneHush/releases/latest) 下载 **SceneHush-1.2.5-universal.dmg**。
2. 如为升级，请先恢复显示并退出旧版 SceneHush。
3. 打开 DMG，先查看拖动安装和 macOS 拦截时的放行提示。
4. 将 **SceneHush.app** 拖到**应用程序**，再从应用程序打开。完成或跳过引导后进入设置。

需要 macOS 13 或更新版本，支持 Apple Silicon 与 Intel。打开 DMG 不会执行 SceneHush、更改 Gatekeeper 设置或自动解除下载隔离。使用备选 ZIP 时，先解压，再将 SceneHush.app 拖到应用程序。

### 如果 macOS 拦截 App

此版本尚无 Developer ID 签名及 Apple 公证。安装提示会提前说明放行步骤，无法消除 Gatekeeper 警告。请先确认信任本仓库和下载的 Release，再继续。

1. 从应用程序打开 **SceneHush**。若出现“Apple 无法验证”等提示，点击「**完成**」关闭，不要移到废纸篓。
2. 打开**系统设置 → 隐私与安全性**，向下滚动到「**安全性**」。
3. 找到关于被拦截文件的提示，点击「**仍要打开**」。此按钮可能需要先尝试打开一次文件才会出现。
4. 在后续提示中再次确认「**打开**」，按系统要求认证，App 随后进入使用引导。

官方流程见 Apple 的[在 Mac 上安全地打开 App](https://support.apple.com/en-us/102445)。受管理的 Mac 可能受组织 IT 策略限制。SceneHush 不会更改 Gatekeeper 设置，也不会自动解除下载隔离。

SceneHush 的显示控制和角落检测本身无需管理员、辅助功能或屏幕录制授权。

### 首次使用

每次新安装、重新安装或更新后的首次启动都会显示引导，即使已有旧版设置。完成或跳过一次后，同次安装的普通重启不再重复；原有角落、恢复方式、语言和启用偏好会保留。请从应用程序启动已安装的版本。

点击「**开始**」了解权限，再点击「**试试**」体验可选的 5 秒暗屏渐亮演示。「**跳过**」在右上角，返回箭头在左上角。首次启动跟随 macOS 偏好列表中首个支持的语言，手动语言选择会保留。

**暗屏不等于锁屏。** SceneHush 保留当前桌面会话，不会阻止休眠，也不保证 agent 持续运行。需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 日本語

### アプリケーションへドラッグする

1. [Yoangloo/SceneHush Releases](https://github.com/Yoangloo/SceneHush/releases/latest) から **SceneHush-1.2.5-universal.dmg** をダウンロードします。
2. 更新の場合は、画面を復元して旧版の SceneHush を終了してください。
3. DMG を開き、ドラッグによるインストール方法と macOS にブロックされた場合の手順を確認します。
4. **SceneHush.app** を**アプリケーション**へドラッグしてから、アプリケーションから開きます。ガイドを完了するかスキップすると設定を開けます。

macOS 13 以降の Apple Silicon・Intel Mac に対応します。DMG を開いても SceneHush を実行せず、Gatekeeper 設定やダウンロード隔離属性を自動で変更しません。ZIP の場合は展開し、SceneHush.app をアプリケーションへドラッグしてください。

### macOS がアプリをブロックする場合

このリリースには Developer ID 署名と Apple の公証がありません。インストール手順で許可操作を事前に案内しますが、Gatekeeper の警告はなくせません。リポジトリとダウンロードしたリリースを信頼できる場合のみ続けてください。

1. アプリケーションから **SceneHush** を開きます。Apple が検証できない旨の警告が出たら、「**完了**」で閉じます。ゴミ箱には移動しないでください。
2. **システム設定 → プライバシーとセキュリティ**を開き、「**セキュリティ**」までスクロールします。
3. ブロックされたファイルの通知で「**このまま開く**」を選びます。一度ファイルを開こうとしてからでないと表示されない場合があります。
4. 次の確認で「**開く**」を選び、求められた場合は認証します。続けて SceneHush のガイドが開きます。

公式の手順は Apple の [Safely open apps on your Mac](https://support.apple.com/en-us/102445) を参照してください。組織が管理する Mac では、IT ポリシーで制限される場合があります。SceneHush は Gatekeeper の設定を変更せず、ダウンロード隔離属性を自動で削除しません。

SceneHush の表示制御とコーナー検出に、管理者・アクセシビリティ・画面収録の権限は不要です。

### 初回起動

新規インストール・再インストール・更新後の初回起動では、以前の設定があってもガイドを開きます。一度完了またはスキップすると、同じインストールの通常の再起動では繰り返しません。コーナー、復元方法、言語、有効・無効の設定は引き継ぎます。アプリケーションから起動してください。

「**はじめる**」で権限の説明を確認し、「**試してみる**」で任意の 5 秒間の暗転・復元デモを開始します。「**スキップ**」は右上、戻る矢印は左上です。初回は macOS の優先する言語のうち最初に一致する対応言語を使い、手動で選んだ言語は保存します。

**暗転は画面ロックではありません。** SceneHush は現在のデスクトップをそのまま保ちます。スリープを防ぐ機能や、エージェントの動作継続の保証はありません。無人の Mac を安全に保護する必要がある場合は、macOS の画面ロックを使ってください。
