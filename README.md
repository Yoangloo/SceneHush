<img src="assets/SceneHush.png?v=daynight-1.2.3" alt="SceneHush day and night switch icon" width="96" height="96">

# SceneHush

[English](README.md) · [简体中文](docs/README.zh-CN.md) · [日本語](docs/README.ja.md)

<p>
  <a href="https://github.com/Yoangloo/SceneHush/releases/download/v1.2.5/SceneHush-1.2.5-universal.dmg"><img src="assets/download-macos-en.svg" alt="Download for macOS" width="240" height="48"></a>
</p>

<p>
  <a href="https://github.com/Yoangloo/SceneHush/releases/download/v1.2.5/SceneHush-1.2.5-universal.zip">ZIP</a> · <a href="https://github.com/Yoangloo/SceneHush/releases">All releases</a>
</p>

macOS 13+ · Apple Silicon & Intel · Open the DMG and drag **SceneHush.app** to **Applications**.

[Installation blocked? See the guide.](docs/INSTALL.md#english)

**Screens at rest. Local agents at work.**

SceneHush is a macOS menu bar app for short breaks while **local agents work**. Move the pointer into a chosen corner to darken supported displays while leaving your apps and desktop session in place; move away to restore the screens. **Native macOS control. No companion app required.**

<img src="docs/images/settings-en.png" alt="SceneHush settings in English" width="600">

## Why it exists

Your local coding agent is building, a browser agent is working through a task, or an automation is still running. You need a short break without closing their apps or leaving the current desktop session. SceneHush gives your supported screens a rest, then brings you back to that same session.

SceneHush changes display output without putting a black window over the desktop. It does not send pause commands to your agents, close their apps, or log you out. Some desktop workflows depend on an unlocked session or foreground interaction; other agents continue independently. Capture behavior and agent compatibility still need to be checked in your own environment.

SceneHush does not keep the Mac awake, prevent automatic locking, or guarantee continued agent execution or task completion. It adds no authentication: someone nearby can restore the display and use the unlocked Mac. Use macOS Lock Screen in public or shared spaces, or whenever the computer must be left securely unattended.

## Features

- Choose any of the four corners; the selected corner works on every connected screen.
- Leave local agent apps and the current desktop session in place; SceneHush changes display output without pausing applications.
- Darken supported built-in and external display output together, using native CoreGraphics controls.
- Restore when the pointer leaves, or keep displays dark until the next corner entry.
- Get started with a permission explanation and an optional five-second dark-to-light demonstration.
- Replay the introduction from settings; pause the trigger or restore displays immediately from the menu bar.
- Switch between the system language, English, 简体中文, and 日本語 without restarting.
- Use a centered settings layout, a day/night switch icon, and Liquid Glass controls on macOS 26 or later. Earlier systems use native fallback controls.
- Enable launch at login if you want it.
- Save display state locally before dimming; a watchdog attempts restoration after an unexpected app exit.
- Optionally replace a conflicting macOS Hot Corner, with a backup and an explicit restore action.

## Install and first run

1. Download the DMG from [Releases](https://github.com/Yoangloo/SceneHush/releases/latest). Restore displays and quit an older SceneHush before updating.
2. Open the DMG to see the installation guidance, then drag **SceneHush.app** to **Applications**.
3. Open **SceneHush** from Applications. If Apple cannot verify the app, choose **Done**, then go to **System Settings → Privacy & Security → Open Anyway** and confirm **Open**. See the [installation guide](docs/INSTALL.md#english) for details.
4. In the introduction, choose **Get started** to read the permission explanation, then **Try it** for the optional five-second demonstration. **Skip** is at the top right; the arrow at the top left returns to the previous step.
5. During the demonstration, connected supported displays go dark and gradually return to their saved appearance over five seconds. Press **Escape** to restore immediately. Corner triggers are paused while the introduction is open.
6. Complete or skip the introduction to open settings. Choose a corner, then move the pointer there to try it.

The first launch after installing, reinstalling, or updating opens the introduction, even if an older version was already set up. Complete or skip it once; ordinary relaunches of the same installation do not repeat it. Your corner, restore behavior, language, and enabled-state preferences are retained. Launch from Applications so the installed copy is used.

Only a small sun icon appears in the menu bar; open its menu to see the SceneHush name. There is no Dock icon. The introduction can be replayed from settings, and is not listed in the menu. Its bottom-left corner shows the app version.

On first launch, SceneHush uses the first supported language in your macOS preferred-language list: English, Chinese, or Japanese. If none matches, it uses English. Your manual language choice is saved.

Opening the DMG shows installation guidance; it does not launch SceneHush or change macOS security settings. The ZIP is an alternative for manual installation.

This release has **no Developer ID signing or Apple notarization**. The installation guidance explains Gatekeeper approval in advance; it cannot remove the warning. Continue only if you trust the repository and release, then follow the [Open Anyway steps](docs/INSTALL.md#english). Checksums confirm file consistency; they do not replace notarization.

## Permissions

<img src="docs/images/onboarding-permissions-en.png" alt="SceneHush introduction explaining display, corner, and login permissions" width="420">

Native display control and corner detection need **no Accessibility, Screen Recording, or administrator permission**. SceneHush does not capture your screen or control other apps. The introduction explains this; it does not ask for unused permissions.

**Launch at login is optional.** macOS may require approval in Login Items when you enable it. Any change to a conflicting macOS Hot Corner also requires your choice in the app; the original setting is saved for restoration.

## Requirements and compatibility

- **macOS 13 Ventura or later**, on Apple Silicon or Intel.
- Displays and drivers that support macOS gamma controls. No other display utility is required.

SceneHush adjusts RGB gamma output. It does **not** set the hardware brightness slider to 0%, switch off the backlight, or turn off display power. HDR, virtual displays, and some drivers may not support the control or may override it. A reported failure triggers a restoration attempt and an error; no desktop overlay is added as a fallback.

Display state is saved before changes are applied. The recovery watchdog attempts restoration if the app exits unexpectedly, including during the introduction's demonstration. Recovery is best effort: disconnected or unresponsive screens may need to be reconnected before they can be restored.

When upgrading from a release that controlled brightness through another app, restore displays and quit that release before replacing it. Existing corner, restore, and language preferences are retained; the old dimming-method choice is ignored. Legacy brightness files are not deleted or treated as gamma data. If one is pending, new dimming is blocked until you restore it with the previous release.

## Use

Click the menu bar icon to open settings, select a corner, change restoration behavior, choose a language, pause SceneHush, or restore displays now. The defaults are **bottom right** and **restore when the pointer leaves**.

If macOS already has an action assigned to the selected corner, SceneHush offers to replace it. The change is optional; the previous value is backed up locally and can be restored from settings. You can also change Hot Corners in macOS settings yourself.

To stop using SceneHush, restore displays and quit. Before uninstalling, disable launch at login and restore any macOS Hot Corner that SceneHush replaced.

## Privacy

SceneHush has no analytics, advertising, telemetry, or background network requests. Display identifiers, preferences, and recovery data stay on your Mac in `~/Library/Application Support/SceneHush/`. Opening the project link is an explicit action that opens a website.

## Build from source

Development requires **macOS 14 or later**, a **Swift 6 toolchain**, and a **macOS 26 SDK** from Xcode 26 or corresponding Command Line Tools. The new SDK provides Liquid Glass APIs; the packaged app still supports macOS 13 or later through availability checks. Tests use Swift Testing, and `make test` adapts to the selected Xcode or Command Line Tools installation.

```sh
git clone https://github.com/Yoangloo/SceneHush.git
cd SceneHush
make test
make build
make package
```

The app is built at `build/SceneHush.app`. DMG, ZIP, and SHA-256 checksum files are written to `dist/`. Releases contain **arm64 and x86_64** slices; use `make build ARCH=arm64` for a faster local Apple Silicon build. See [CONTRIBUTING.md](CONTRIBUTING.md) for checks and [VALIDATION.md](docs/VALIDATION.md) for measured results and untested environments.

## Support and license

If SceneHush helps you, [leave a Star on GitHub](https://github.com/Yoangloo/SceneHush) to support the author. The repository address is also available at the bottom of settings.

Use [Issues](https://github.com/Yoangloo/SceneHush/issues) for bugs and suggestions. Include SceneHush and macOS versions, Mac architecture, display connections, HDR or virtual-screen settings, and steps to reproduce. Remove private information from logs and screenshots. See [SECURITY.md](SECURITY.md) and [CHANGELOG.md](CHANGELOG.md).

SceneHush uses the [MIT License](LICENSE). See the [license selection notes](docs/LICENSING.md) for the rationale.
