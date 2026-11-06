# Contributing to SceneHush

Keep changes focused and describe the user-visible behavior they change.

## Development setup

Use macOS 14 or later, Swift 6, and a macOS 26 SDK from Xcode 26 or corresponding Command Line Tools. Liquid Glass APIs require the new SDK; availability checks retain macOS 13 runtime support. Automated tests must use test doubles and must not change the developer's display state.

```sh
git clone https://github.com/Yoangloo/SceneHush.git
cd SceneHush
make test
make build
```

Use `make package` for DMG/ZIP archives and checksums. The app is generated at `build/SceneHush.app`, and packages at `dist/`. Packaging builds arm64 and x86_64 by default. Use `make build ARCH=arm64` or `make build ARCH=x86_64` for a faster single-architecture build; runtime testing still requires suitable hardware.

## Before opening a pull request

1. Make one focused change, reproduce the issue, and add a meaningful test for a behavior change.
2. Run `make test` first, then `make build` for changes affecting compilation or resources.
3. Keep configuration and recovery compatible or implement explicit migration. Preserve unresolved display state, including snapshots for disconnected displays. Old external-app brightness files must not be mistaken for gamma data or silently removed.
4. Update English, Simplified Chinese, and Japanese together. Language changes must work without restarting.
5. Describe the problem, resulting behavior, and validation. Include actual screenshots for visible UI changes.

Do not add telemetry, background network calls, third-party binary downloads, credentials, or machine-specific paths. SceneHush uses native display control only.

## Manual checks for display changes

Begin with known RGB tables on every screen and a working restoration path. Confirm every supported connected display darkens and each one restores its original table. Verify gamma values rather than the hardware brightness slider. Test an internal and external screen when available, and name untested setups such as HDR and virtual displays.

Do not create a black desktop overlay as a fallback. Driver success and gamma readback alone do not establish physical display behavior or compatibility with all agents. Test the actual screen-capture path before making claims. If a display rejects a change, restore saved state and report the error.

For corners, test all four choices and layouts with negative coordinates. For recovery, test partial failure, interruption, disconnection and reconnection. Native Hot Corner changes remain optional, with a saved original value and a working restore action.

## Introduction and visual checks

Walk through a fresh launch, permission explanation, an explicitly started five-second demonstration, restoration, and entry into settings. Confirm the introduction can be skipped and replayed, corner triggers stay paused while it is open, and Escape or closing during the demonstration restores displays. Check failure and crash recovery during the fade, not just after it.

Check English, Simplified Chinese, and Japanese for clipping, keyboard access, focus, and aligned controls. Inspect Liquid Glass on macOS 26+ and the fallback on older systems when available. Respect Reduce Motion for decorative movement; the intentional display demonstration must remain optional with an immediate restoration action. Do not describe a screenshot as proof of smooth animation.

## Release checks

- Test and build from a clean checkout, then package the universal app.
- Verify version, both architectures, minimum macOS version, and all translations.
- Walk through menu, settings, first run, replay, optional login item, dimming, and restoration.
- Check package contents and SHA-256 checksums.
- State the actual signing and notarization status; ad-hoc is not Developer ID or notarization.
- Publish tag, three-language release notes, DMG, ZIP, and checksums together, then verify public downloads.
- Record observed results and remaining gaps in [VALIDATION.md](docs/VALIDATION.md).

## License

Contributions use this repository's MIT License. Only contribute material you have the right to share.
