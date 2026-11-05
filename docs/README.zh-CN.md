<img src="../assets/SceneHush.png" alt="SceneHush 图标" width="96" height="96">

# SceneHush

[English](../README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md)

**把屏幕的安静，放在一个角落。**

SceneHush 是一个轻量 macOS 菜单栏 App。将鼠标移到选定的屏幕角落，让已连接且支持控制的屏幕暗下来；默认移开鼠标后，恢复各屏原来的显示状态。**1.1 版可独立运行，不再要求安装 BetterDisplay。**

<img src="images/settings-zh-Hans.png" alt="SceneHush 简体中文原生 macOS 设置界面" width="600">

## 为什么做这个工具

项目起于一个具体需求：MacBook 同时连接外接显示器时，希望把鼠标移到右下角，就能用电脑上已有的 BetterDisplay 将**两块屏幕一起调到 0**。最初的右下角动作，后来扩展成了 SceneHush：有独立名称的菜单栏 App，可以选择四个角、保存配置，并切换三种界面语言。

接下来的需求是：为了短暂离席这个简单动作，能否不必再装另一个显示器工具？因此，新版默认通过 macOS 原生显示伽马控制独立工作，同时把 BetterDisplay 保留为可选兼容模式。

它面向这样一个场景：电脑上的 agent 正在工作，人想短暂离开，让屏幕暗下来。一些 agent 流程依赖可见桌面、未锁定的用户会话或前台交互；锁屏、睡眠或交互暂停，可能打断其中的步骤。另一些 agent 可以独立运行。SceneHush 调暗显示输出，让当前桌面会话保持原样。原生模式不添加桌面遮罩，但截图表现及 agent 兼容性仍需在自己的环境中验证。

它不会阻止电脑睡眠或自动锁屏，也不保证 agent 持续运行或完成任务。它同样没有身份验证：旁人可以恢复亮度，继续操作这台未锁定的 Mac。公共、共享环境，或需要安全地无人看管电脑时，请使用 macOS 系统锁屏。

## 功能

- 四个角任选，所选角落在每块已连接的屏幕上都能触发。
- 同时调暗受支持的 MacBook 内置屏和外接屏显示输出，原生模式无需其他 App。
- 默认移开鼠标恢复；也可选择保持调暗，再次进入角落时恢复。
- 在菜单栏中随时启用或暂停。
- 界面支持跟随系统、English、简体中文和日本語，切换后立即生效。
- 可选登录时自动启动。
- 调暗前在本机保存原显示状态，异常退出后可恢复。
- 可选择原生调暗或 BetterDisplay 兼容模式。
- 可选择替换有冲突的 macOS 快捷角，并备份原设置，供手动还原。

SceneHush **不会锁定 macOS**。原生模式调整显示屏的 RGB 伽马输出，不会将硬件亮度滑块设为 0%，也不保证背光关闭或显示屏断电。暗屏不构成隐私或安全边界。

## 使用要求

- **macOS 13 Ventura 或更新版本**，支持 Apple Silicon 和 Intel Mac。
- 原生模式需要显示器及驱动支持 macOS 伽马控制。

**BetterDisplay 是可选项。** 如需使用其兼容模式，请另行安装并运行 [BetterDisplay](https://github.com/waydabber/BetterDisplay)，在其设置中启用**命令行集成**。SceneHush 安装包不包含 BetterDisplay。

## 显示器兼容性

原生模式通过 CoreGraphics 伽马表调暗显示输出，不会在桌面上添加黑色窗口。HDR、虚拟显示屏以及部分显示驱动可能不支持该控制，或会覆盖设置。系统报告调暗失败时，SceneHush 会尝试回滚已保存的状态并提示错误；可针对这套设备尝试可选的 BetterDisplay 模式。两种模式都不保证屏幕断电，也不保证兼容所有显示器或 agent 截图流程。

恢复监护仅覆盖**原生模式**，在主程序异常退出时尝试还原保存的伽马状态。BetterDisplay 模式使用独立的亮度快照恢复流程，不受这个监护进程保护。恢复并非绝对保证；断开或未响应的显示器可能需要重新连接后才能还原。

## 安装

1. 从 [Releases](https://github.com/Yoangloo/SceneHush/releases/latest) 下载 DMG 或 ZIP。
2. 打开 DMG，将 **SceneHush.app** 拖到**应用程序**；如果下载 ZIP，解压后将 App 移到应用程序文件夹。
3. 打开 SceneHush。顶部菜单栏仅显示图标；点击图标展开菜单后，可看到名称 SceneHush。Dock 中不显示图标。
4. 将调暗方式保持为**原生模式**，即可不依赖 BetterDisplay 使用。
5. 点击菜单栏图标，选择触发角落，再将鼠标移到该角落试用。如原生控制不受支持，请先恢复屏幕，再尝试可选的 BetterDisplay 模式。

此版本使用 **ad-hoc 签名，尚无 Developer ID 签名及 Apple 公证**。如果 macOS 阻止打开，请先确认你信任本仓库和下载的 Release，再到**系统设置 → 隐私与安全性 → 仍要打开**。也可以从源码自行构建。下载校验和用于确认文件一致性，不能替代 Apple 公证。

## 使用

点击菜单栏中的 **SceneHush 图标**，展开后可看到 App 名称，并可选择触发角落、调暗方式、恢复方式、语言，或暂停触发、立即恢复屏幕。默认使用**原生模式**和**右下角**，恢复方式为**移开鼠标后恢复**。

如果所选角落已有 macOS 快捷角动作，SceneHush 会提供替换选项，由你选择是否替换。原设置会保存在本机，并可通过 SceneHush 设置中的还原操作恢复；也可以自行在 macOS 设置中调整快捷角。

需要开机后继续使用时，可启用登录自动启动。停用前先恢复亮度并退出；卸载前关闭登录自动启动。如果曾替换系统快捷角，请先还原，再移除 App。

## 隐私

SceneHush 不含分析、广告、遥测或后台网络请求。显示屏标识、配置和显示恢复数据只保存在本机的 `~/Library/Application Support/SceneHush/`。只有主动点击项目或可选 BetterDisplay 链接时，才会打开对应网站。

## 从源码构建

开发环境需要 **macOS 14 或更新版本**及 **Swift 6 工具链**，包含 Xcode 或 Xcode Command Line Tools 提供的 macOS SDK。测试使用 Swift Testing；`make test` 会运行项目测试脚本，自动适配当前选中的 Xcode 或 Command Line Tools 安装。这些是开发环境要求，打包后的 App 仍支持 **macOS 13 或更新版本**。

```sh
git clone https://github.com/Yoangloo/SceneHush.git
cd SceneHush
make test
make build
make package
```

App 生成在 `build/SceneHush.app`；DMG、ZIP 和 SHA-256 校验文件生成在 `dist/`。默认发布版本为同时支持 **arm64 和 x86_64** 的通用二进制。在 Apple Silicon 上快速本地构建可使用 `make build ARCH=arm64`；公开发布使用默认通用版本。开发与验证说明见 [CONTRIBUTING.md](../CONTRIBUTING.md)。

原生模式本次实测结果及未覆盖的环境见[验证记录](VALIDATION.md)。

## 反馈与贡献

欢迎通过 [Issues](https://github.com/Yoangloo/SceneHush/issues) 提交问题和建议。请提供 macOS 版本、Mac 架构、所选调暗方式、显示器连接情况（包括 HDR 或虚拟屏）及复现步骤。仅在使用 BetterDisplay 模式时补充其版本。安全问题参见 [SECURITY.md](../SECURITY.md)，更新内容参见 [CHANGELOG.md](../CHANGELOG.md)。

## 开源协议

SceneHush 使用 [MIT 协议](../LICENSE)。可选的 BetterDisplay 产品仍受其自身协议约束。[协议选择说明](LICENSING.md) 记录了本项目的选择理由。
