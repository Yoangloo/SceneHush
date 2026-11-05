<img src="assets/SceneHush.png" alt="SceneHush icon" width="96" height="96">

# SceneHush

[English](README.md) · [简体中文](docs/README.zh-CN.md) · [日本語](docs/README.ja.md)

**A quiet corner for all your screens.**

SceneHush is a small macOS menu bar app. Move the pointer into your chosen screen corner to set every connected, supported display to **0% brightness through BetterDisplay**. By default, moving away restores each display's previous brightness.

<img src="docs/images/settings-en.png" alt="SceneHush native macOS settings in English" width="600">

## Why it exists

This project started with a practical request: on a MacBook with an external monitor, make the bottom-right corner lower **both** screens to zero using the BetterDisplay already installed. That first corner action became SceneHush: a named menu bar app with a choice of all four corners, saved preferences, and three interface languages.

The use case is a short break while an agent is working on your computer. Some agent workflows depend on a visible desktop, an unlocked user session, or foreground interaction; locking the screen, sleeping the Mac, or pausing that interaction can interrupt those particular steps. Other agents continue independently. SceneHush offers a separate choice: adjust screen brightness while leaving the current desktop session as it is.

It does not keep the Mac awake, prevent automatic locking, or guarantee that an agent continues or finishes its work. It also adds no authentication: another person can restore the brightness and use the unlocked Mac. Use macOS Lock Screen in public or shared spaces, or whenever the computer must be left securely unattended.

## Features

- Choose any of the four corners. The chosen corner works on every connected screen.
- Dim the MacBook display and external displays together.
- Restore on pointer exit, or keep displays dimmed until the next corner entry.
- Enable or pause the trigger from the menu bar.
- Switch the interface between the system language, English, 简体中文, and 日本語 immediately.
- Start automatically at login when you enable it.
- Save brightness locally before dimming and recover it after an interrupted session.
- Optionally replace a conflicting macOS Hot Corner, with a backup and an explicit restore action.

SceneHush adjusts brightness; it does **not** lock macOS. A BetterDisplay value of 0% is the lowest configured brightness, not a guarantee that a display's backlight or power is off. A dark screen is not a privacy or security boundary.

## Requirements

- macOS **13 Ventura or later**, on Apple Silicon or Intel.
- [BetterDisplay](https://github.com/waydabber/BetterDisplay), installed and running.
- BetterDisplay's **command-line integration** enabled in its integration settings.

SceneHush uses BetterDisplay's existing display controls. Which external displays can be controlled depends on the monitor, connection, and BetterDisplay configuration. BetterDisplay is a separate product and is not included in this download.

## Install

1. Download the DMG or ZIP from [Releases](https://github.com/Yoangloo/SceneHush/releases/latest).
2. Open the DMG and drag **SceneHush.app** into **Applications**. For a ZIP, extract it and move the app into Applications.
3. Open SceneHush. Its name and icon appear in the menu bar; it does not need a Dock icon.
4. Make sure BetterDisplay is running and command-line integration is enabled.
5. Open SceneHush's menu, choose a corner, and move the pointer into that corner to try it.

The initial release is **ad-hoc signed, without Developer ID signing or Apple notarization**. If macOS blocks it, only after confirming that you trust this repository and its release, use **System Settings → Privacy & Security → Open Anyway**. Building from source is another option. Release checksums identify the downloaded files; they do not replace Apple notarization.

## Use

Click **SceneHush** in the menu bar to choose a trigger corner, change the restore behavior, select a language, pause the app, or restore brightness immediately. The default corner is **bottom right**, and the default restore behavior is **restore when the pointer leaves**.

If macOS already assigns an action to the selected corner, SceneHush offers to replace that action. The change is optional. Its previous value is backed up locally and can be restored explicitly from SceneHush's settings. You can also change Hot Corners yourself in macOS settings.

Enable launch at login from the app if you want it available after restarting your Mac. To stop using SceneHush, restore brightness and quit it; disable launch at login before removing the app. Restore any macOS Hot Corner you replaced before uninstalling.

## Privacy

SceneHush has no analytics, advertising, telemetry, or background network requests. Display identifiers, configuration, and brightness recovery data stay on your Mac in `~/Library/Application Support/SceneHush/`. Opening a project or BetterDisplay link is an explicit action that opens a website.

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

## Support and contributions

Use [Issues](https://github.com/Yoangloo/SceneHush/issues) for bugs and feature requests. Include your macOS version, Mac architecture, BetterDisplay version, display setup, and steps to reproduce. See [SECURITY.md](SECURITY.md) for security reports and [CHANGELOG.md](CHANGELOG.md) for changes.

## License

SceneHush is released under the [MIT License](LICENSE). BetterDisplay remains subject to its own license. See the [license selection notes](docs/LICENSING.md) for the project's rationale.
