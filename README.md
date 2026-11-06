<img src="assets/SceneHush.png" alt="SceneHush day and night switch icon" width="96" height="96">

# SceneHush

[English](README.md) · [简体中文](docs/README.zh-CN.md) · [日本語](docs/README.ja.md)

**Screens at rest. Work in motion.**

SceneHush is a small, standalone macOS menu bar app. Move the pointer into your chosen screen corner to darken connected, supported displays; move away to restore their previous appearance. **Version 1.2 uses native macOS display control only. No companion app is required.**

<img src="docs/images/settings-en.png" alt="SceneHush settings in English" width="600">

## Why it exists

The first request was simple: on a MacBook with an external monitor, make one corner darken both screens. SceneHush grew from that action into a quiet utility for short breaks while a computer agent has work in progress. Choose a corner, step away briefly, and return to the same desktop session.

SceneHush changes display output without putting a black window over the desktop. It does not send pause commands to your agents, close their apps, or log you out. Some desktop workflows depend on an unlocked session or foreground interaction; other agents continue independently. Capture behavior and agent compatibility still need to be checked in your own environment.

SceneHush does not keep the Mac awake, prevent automatic locking, or guarantee continued agent execution or task completion. It adds no authentication: someone nearby can restore the display and use the unlocked Mac. Use macOS Lock Screen in public or shared spaces, or whenever the computer must be left securely unattended.

## Features

- Choose any of the four corners; the selected corner works on every connected screen.
- Darken supported built-in and external display output together, using native CoreGraphics controls.
- Restore when the pointer leaves, or keep displays dark until the next corner entry.
- Get started with a permission explanation and an optional five-second dark-to-light demonstration.
- Replay the introduction from the app; pause the trigger or restore displays immediately from the menu bar.
- Switch between the system language, English, 简体中文, and 日本語 without restarting.
- Use a centered settings layout, a day/night switch icon, and Liquid Glass controls on macOS 26 or later. Earlier systems use native fallback controls.
- Enable launch at login if you want it.
- Save display state locally before dimming; a watchdog attempts restoration after an unexpected app exit.
- Optionally replace a conflicting macOS Hot Corner, with a backup and an explicit restore action.

## Install and first run

1. Download the DMG or ZIP from [Releases](https://github.com/Yoangloo/SceneHush/releases/latest).
2. Drag **SceneHush.app** into **Applications**, then open it. For a ZIP, extract the app first.
3. The introduction explains what changes and which permissions are needed. Choose the five-second demonstration when you are ready, or skip it.
4. During the demonstration, connected supported displays go dark and gradually return to their saved appearance over five seconds. Press **Escape** to restore immediately. Corner triggers are paused while the introduction is open.
5. Finish the introduction to open settings. Choose a corner, then move the pointer there to try it.

Only an icon appears in the menu bar; open its menu to see the SceneHush name. There is no Dock icon. You can replay the introduction later.

This release is **ad-hoc signed, without Developer ID signing or Apple notarization**. If macOS blocks it, confirm that you trust the repository and release, then use **System Settings → Privacy & Security → Open Anyway**. Building from source is another option. Checksums confirm file consistency; they do not replace notarization.

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
