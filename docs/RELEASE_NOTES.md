# SceneHush 1.2.3

## English

**Screens at rest. Local agents at work.** The app introduction and README now focus on short breaks while local agents work: dim supported screens while keeping their apps and the current desktop session in place. SceneHush does not pause applications or add a keepawake feature.

The introduction now places **Skip** at the top right. The top-left **Back** control uses only an arrow, with a localized accessibility name and help.

The main actions remain **Get started**, then **Try it**. The bottom left shows the app version, and the language selector stays at the bottom right. English, Simplified Chinese, and Japanese follow the same layout. Introduction replay remains available from settings.

Each README now has a prominent macOS download button near the top, with ZIP and all-release links beside it. On first launch, the app follows the first supported language in your macOS preferred-language list: English, Chinese, or Japanese, falling back to English when none matches. Manual language choices are retained.

The day/night switch artwork is unchanged. A new bundle icon resource filename and versioned README image references help macOS and GitHub refresh the displayed icon.

Window sizing stays under AppKit control to prevent content measurements from moving or resizing the window during display changes. Introduction transitions animate the content only.

SceneHush continues to use native macOS display control, with no companion app. Your corner, restore behavior, language, and introduction preferences are retained. Restore displays and quit an older release before updating.

**Compatibility and installation:** macOS 13+, Apple Silicon or Intel, and compatible display gamma control are required. Download the universal DMG or ZIP and move SceneHush.app into Applications. The app darkens RGB output; it does not set the hardware brightness slider to zero or turn off the backlight. HDR, virtual displays, and some drivers may be unsupported. This release is ad-hoc signed and not Apple-notarized. If blocked, confirm the release source and your trust before using System Settings → Privacy & Security → Open Anyway.

**Dimming is not locking.** Anyone nearby can restore the display and use the unlocked Mac. SceneHush does not pause agents, prevent sleep or automatic locking, or guarantee task completion. Use macOS Lock Screen when the computer must be left securely unattended.

## 简体中文

**屏幕歇一会，本地 agent 继续工作。** App 引导和 README 统一突出本地 agent 工作期间的短暂离席：调暗受支持屏幕，保留 App 与当前桌面会话。SceneHush 不会暂停应用，也没有增加保活或防休眠功能。

引导中的「**跳过**」移到右上角。左上角的返回按钮只显示箭头，保留本地化的可访问性名称和提示。

主要操作仍为先「**开始**」，再「**试试**」。左下角显示 App 版本，语言选择保留在右下角。英中日三语沿用相同布局，设置页仍可重看引导。

三语 README 首屏新增醒目的 macOS 下载按钮，旁边提供 ZIP 和所有版本入口。App 首次启动按 macOS 语言偏好顺序使用首个支持的语言（英语、中文或日语），无匹配时使用英语；手动语言选择会保留。

日月 Switch 图案保持原样，通过新的 App 图标资源文件名和 README 图片版本标记，帮助 macOS 与 GitHub 刷新显示的图标。

窗口尺寸交由 AppKit 管理，避免切换显示屏时内容尺寸测量引起窗口移动或缩放；引导只对内容切换应用动画。

SceneHush 仍使用 macOS 原生显示控制，无需配套 App。原有角落、恢复方式、语言和引导偏好会保留。升级前请先恢复显示并退出旧版。

**兼容性与安装：** 需要 macOS 13+、Apple Silicon 或 Intel，以及兼容的显示伽马控制。下载通用版 DMG 或 ZIP，将 SceneHush.app 移到应用程序。调暗的是 RGB 显示输出，不会把硬件亮度滑块设为 0% 或关闭背光；HDR、虚拟屏及部分驱动可能不支持。此版本使用 ad-hoc 签名，尚未经过 Apple 公证。如被拦截，请先核对并确认信任发布来源，再到系统设置 → 隐私与安全性 → 仍要打开。

**暗屏不等于锁屏。** 旁人仍可恢复显示并操作未锁定的 Mac。SceneHush 不会暂停 agent、阻止休眠或自动锁屏，也不保证任务完成。需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 日本語

**画面はひと休み。ローカルエージェントは作業中。** アプリのガイドと README は、ローカルエージェントの作業中の短い離席を中心に説明します。アプリと現在のデスクトップを維持し、対応画面だけを暗くします。アプリを一時停止せず、スリープ防止の機能も追加していません。

ガイドの「**スキップ**」を右上に移動しました。左上の戻るボタンは矢印だけを表示し、アクセシビリティ用の名前とヘルプは選択した言語で表示します。

主な操作は引き続き「**はじめる**」、次に「**試してみる**」です。左下にはアプリのバージョン、右下には言語選択を表示します。英語・簡体字中国語・日本語で同じレイアウトを使い、設定画面からガイドを再表示できます。

各 README の冒頭に macOS 版のダウンロードボタンを設け、ZIP とすべてのリリースへのリンクを並べました。初回起動では macOS の優先する言語のうち、対応する英語・中国語・日本語で最初に一致する言語を使います。一致しない場合は英語を使い、手動の言語選択は保持します。

昼夜スイッチの図案は変更していません。アプリ内のアイコンリソースに新しいファイル名を使い、README の画像参照にはバージョンを付けて、macOS と GitHub でのアイコン表示の更新を促します。

ウインドウのサイズは AppKit で管理し、画面の切り替え時にコンテンツの計測で位置やサイズが変わることを防ぎます。ガイドのアニメーションはコンテンツの切り替えだけに適用します。

SceneHush は引き続き macOS 標準の表示制御を使い、追加アプリは不要です。コーナー、復元方法、言語、ガイドの設定は引き継ぎます。更新前に画面を復元して旧版を終了してください。

**互換性とインストール：** macOS 13+、Apple Silicon または Intel、および対応するガンマ制御が必要です。Universal 版 DMG または ZIP をダウンロードし、SceneHush.app をアプリケーションへ移動します。暗くするのは RGB 出力であり、ハードウェアの輝度をゼロにしたりバックライトを消したりしません。HDR、仮想画面、一部のドライバーは非対応の場合があります。このリリースは ad-hoc 署名で、Apple の公証はありません。起動がブロックされた場合は、配布元を信頼できることを確認してから、システム設定 → プライバシーとセキュリティ → このまま開くを選択してください。

**暗転は画面ロックではありません。** 他の人が画面を戻して、ロックされていない Mac を操作できます。SceneHush はエージェントを一時停止せず、スリープや自動ロックを防がず、タスクの完了も保証しません。無人の Mac を安全に保護する必要がある場合は、macOS の画面ロックを使ってください。
