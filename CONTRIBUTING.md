# Contributing to SceneHush

Thank you for helping improve SceneHush. Keep changes focused and describe the user-visible behavior they change.

## Development setup

Use a Mac with Xcode Command Line Tools installed. Native mode runs without BetterDisplay. Testing the optional BetterDisplay mode requires that separate app and its command-line integration. Automated tests should use test doubles and must not change the developer's display state.

```sh
git clone https://github.com/Yoangloo/SceneHush.git
cd SceneHush
make test
make build
```

For a distributable app and archives:

```sh
make package
```

The app is generated at `build/SceneHush.app`; packages and checksums are generated in `dist/`. Packaging builds both arm64 and x86_64 slices by default, so a machine does not need to match the release architecture. For a faster native build, use `make build ARCH=arm64` or `make build ARCH=x86_64`. Running the app still requires macOS and a supported architecture.

## Before opening a pull request

1. Make a branch for one change, reproduce the issue, and add a meaningful test for a behavior change.
2. Run `make test` before building the app. Run `make build` after changes that affect compilation or resources.
3. Keep configuration and recovery formats compatible, or add an explicit migration. Never discard a saved display state just because its display is temporarily disconnected. Native gamma snapshots and legacy BetterDisplay brightness snapshots must remain distinguishable.
4. Update English, Simplified Chinese, and Japanese together when changing user-facing text. All language choices must work without restarting the app.
5. Explain the problem, resulting behavior, and validation in the pull request. Include a screenshot when changing visible UI.

Do not add telemetry, background network calls, third-party binary downloads, credentials, or machine-specific paths. BetterDisplay is an optional external dependency; do not bundle or redistribute it in SceneHush releases.

## Manual checks for display changes

Test with display recovery available and a known starting state on each display. Confirm that entering the selected corner dims every connected supported screen, and that the selected restore behavior brings each screen back to its own starting state. For native mode, verify gamma-table values and restoration; the hardware brightness slider is not its control. For BetterDisplay mode, check the saved brightness and automatic-brightness state. Check at least one internal and one external display when hardware is available; report the setups you could not test, including HDR and virtual displays.

Native mode must not create a desktop overlay. That does not establish compatibility with every screen-capture or agent workflow: test the actual capture path before making a claim about it. Driver success and a readable gamma table alone do not prove that every display physically went black. If a driver rejects dimming, attempt rollback and report the failure instead of silently adding an overlay.

For changes to corner selection, verify all four choices and screen layouts with negative coordinates. For recovery changes, check failure partway through dimming, app interruption, and disconnecting and reconnecting a display. Changes to macOS Hot Corners must remain optional, preserve backups, and have a working restore action.

## Release checks

- Run the automated tests and build/package commands from a clean checkout.
- Verify that the app contains both architectures, the expected version, and all three translations.
- Open the packaged app without BetterDisplay and check native mode. Check optional-mode guidance separately, and try the menu, settings, login item, dimming, and restoration.
- Confirm that packages contain only intended app/source content, and record their SHA-256 checksums.
- State the actual signing and notarization status in the release. Do not describe an ad-hoc signature as Developer ID signing or notarization.
- Publish the tag, release notes, DMG, ZIP, and checksums together. Verify the public download links after publishing.

## License

Contributions are accepted under this repository's MIT License. Only contribute material you have the right to share.
