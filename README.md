<img src="assets/SceneHush.png" alt="SceneHush icon" width="96" height="96">

# SceneHush

[English](README.md) · [简体中文](docs/README.zh-CN.md) · [日本語](docs/README.ja.md)

**A quiet corner for all your screens.**

SceneHush is a small macOS menu bar app. Move the pointer into your chosen screen corner to make connected, supported displays dark, then move away to restore their previous appearance. **Version 1.1 runs on its own: BetterDisplay is no longer required.**

<img src="docs/images/settings-en.png" alt="SceneHush native macOS settings in English" width="600">

## Why it exists

This project started with a practical request: on a MacBook with an external monitor, make the bottom-right corner lower **both** screens to zero using the BetterDisplay already installed. That first corner action became SceneHush: a named menu bar app with a choice of all four corners, saved preferences, and three interface languages.

The next step was to make that short-break action work without installing another display utility. SceneHush now uses macOS's native display gamma controls by default, with BetterDisplay available as an optional compatibility mode.

The use case is a short break while an agent is working on your computer. Some agent workflows depend on a visible desktop, an unlocked user session, or foreground interaction; locking the screen, sleeping the Mac, or pausing that interaction can interrupt those particular steps. Other agents continue independently. SceneHush dims display output while leaving the current desktop session as it is. Native mode adds no desktop overlay, but capture behavior and agent compatibility still need to be checked in your own environment.

It does not keep the Mac awake, prevent automatic locking, or guarantee that an agent continues or finishes its work. It also adds no authentication: another person can restore the brightness and use the unlocked Mac. Use macOS Lock Screen in public or shared spaces, or whenever the computer must be left securely unattended.

## Features

- Choose any of the four corners. The chosen corner works on every connected screen.
- Dim supported MacBook and external display output together, with no extra app in native mode.
- Restore on pointer exit, or keep displays dimmed until the next corner entry.
- Enable or pause the trigger from the menu bar.
- Switch the interface between the system language, English, 简体中文, and 日本語 immediately.
- Start automatically at login when you enable it.
- Save the original display state locally before dimming and recover it after an interrupted session.
- Choose native display dimming or optional BetterDisplay compatibility mode.
- Optionally replace a conflicting macOS Hot Corner, with a backup and an explicit restore action.

SceneHush does **not** lock macOS. Native mode changes the display's RGB gamma output; it does not set the hardware brightness slider to 0% or guarantee backlight or power-off. A dark screen is not a privacy or security boundary.

## Requirements

- macOS **13 Ventura or later**, on Apple Silicon or Intel.
- A display and driver that support macOS gamma controls for native mode.

**BetterDisplay is optional.** To use its compatibility mode, install and run [BetterDisplay](https://github.com/waydabber/BetterDisplay) separately and enable its **command-line integration**. It is not bundled with SceneHush.

## Display compatibility

Native mode uses CoreGraphics gamma tables to dim display output without placing a black window over the desktop. HDR, virtual displays, and some display drivers may not support this control or may override it. SceneHush attempts to restore saved state after a reported dimming failure and shows an error; you can try the optional BetterDisplay mode for that setup. Neither mode guarantees physical display power-off or compatibility with every display or agent capture workflow.

The recovery watchdog covers **native mode only**. It attempts to restore saved gamma state if the main app exits unexpectedly. BetterDisplay mode uses its separate saved-brightness restoration path and is not monitored by this watchdog. Recovery is best effort; a disconnected or unresponsive display may need to be reconnected before it can be restored.

## Install

1. Download the DMG or ZIP from [Releases](https://github.com/Yoangloo/SceneHush/releases/latest).
2. Open the DMG and drag **SceneHush.app** into **Applications**. For a ZIP, extract it and move the app into Applications.
3. Open SceneHush. Only its icon appears in the menu bar; click the icon to see the app name in the menu. There is no Dock icon.
4. Leave the dimming method on **Native** to use SceneHush without BetterDisplay.
5. Click its menu bar icon, choose a corner, and move the pointer into that corner to try it. If native control is unsupported, restore the displays and try the optional BetterDisplay mode.

This release is **ad-hoc signed, without Developer ID signing or Apple notarization**. If macOS blocks it, only after confirming that you trust this repository and its release, use **System Settings → Privacy & Security → Open Anyway**. Building from source is another option. Release checksums identify the downloaded files; they do not replace Apple notarization.

## Use

Click the **SceneHush icon** in the menu bar. The opened menu shows the app name and lets you choose a trigger corner, change the dimming method or restore behavior, select a language, pause the app, or restore the displays immediately. The defaults are **Native**, **bottom right**, and **restore when the pointer leaves**.

If macOS already assigns an action to the selected corner, SceneHush offers to replace that action. The change is optional. Its previous value is backed up locally and can be restored explicitly from SceneHush's settings. You can also change Hot Corners yourself in macOS settings.

Enable launch at login from the app if you want it available after restarting your Mac. To stop using SceneHush, restore brightness and quit it; disable launch at login before removing the app. Restore any macOS Hot Corner you replaced before uninstalling.

## Privacy

SceneHush has no analytics, advertising, telemetry, or background network requests. Display identifiers, configuration, and display recovery data stay on your Mac in `~/Library/Application Support/SceneHush/`. Opening a project or optional BetterDisplay link is an explicit action that opens a website.

## Build from source

Development requires **macOS 14 or later** and a **Swift 6 toolchain**, including the macOS SDK from Xcode or Xcode Command Line Tools. The test suite uses Swift Testing. `make test` runs the project test script, which automatically adapts to the selected Xcode or Command Line Tools installation. These are development requirements; the packaged app supports **macOS 13 or later**.

```sh
git clone https://github.com/Yoangloo/SceneHush.git
cd SceneHush
make test
make build
make package
```

The app is built at `build/SceneHush.app`. Packaging writes the DMG, ZIP, and SHA-256 checksum file into `dist/`. The default release app is a universal binary for **arm64 and x86_64**. For a faster local build on Apple Silicon, use `make build ARCH=arm64`; public releases use the universal default. See [CONTRIBUTING.md](CONTRIBUTING.md) for development and verification details.

Measured native-mode results and untested environments are recorded in [VALIDATION.md](docs/VALIDATION.md).

## Support and contributions

Use [Issues](https://github.com/Yoangloo/SceneHush/issues) for bugs and feature requests. Include your macOS version, Mac architecture, selected dimming method, display setup (including HDR or virtual displays), and steps to reproduce. Include the BetterDisplay version only if you use that mode. See [SECURITY.md](SECURITY.md) for security reports and [CHANGELOG.md](CHANGELOG.md) for changes.

## License

SceneHush is released under the [MIT License](LICENSE). The optional BetterDisplay product remains subject to its own license. See the [license selection notes](docs/LICENSING.md) for the project's rationale.
