# Drag-to-Applications distribution

`scripts/package.sh` produces a read-only DMG, a ZIP for manual app installation,
and SHA-256 sums for both. It does not build an Installer package.

```sh
scripts/package.sh --arch universal
python3 scripts/installer/verify-package.py --arch universal
```

Packaging requires macOS, Xcode command line tools, and Python 3.9 or later.
There are no pip installs or network requests. The MIT-licensed DS_Store and legacy alias
helpers are included as unmodified source; their versions, provenance and
upstream hashes are documented in [dmg/vendor/README.md](dmg/vendor/README.md).
Apple frameworks render the background image, create its native bookmark,
and independently resolve both the alias and bookmark data.

## What users see

Double-clicking the read-only DMG normally opens its volume in Finder, as
documented by `hdiutil(1)` under `attach -[no]autoopen`. The fixed icon view
shows `SceneHush.app`, an Applications shortcut, an arrow, and three short
installation steps in English, Simplified Chinese and Japanese. Instructions
to dismiss a verification warning and use **System Settings > Privacy &
Security > Open Anyway** are visible in that same window before the app runs.

A separate `Installation Guide.html` provides the full three-language process,
a user-initiated settings link and its manual fallback, and Apple's official
help link. Its styles and icon are embedded, so the guide works offline. It
chooses the browser's first supported preferred language and offers language
buttons. Opening or mounting the DMG does not start SceneHush, install anything,
or change display or security settings.

Users drag the app into Applications, then open it from Applications. Restore
the displays and quit an older SceneHush before replacing it. Existing app
preferences remain outside the app bundle and are preserved. The installed app
then shows its introduction for a new installation or update; users can finish
or skip it to reach settings.

## Finder background

Packaging creates a temporary writable HFS+ image and mounts it with
`-nobrowse -noautoopen`. Apple Foundation creates a minimal bookmark for the
background inside that volume; the vendored helper creates its legacy alias.
The bookmark preserves native path and volume metadata while removing backing-image
locators, extra tables and security-scope data. The DS_Store writer records those references, window
settings and icon positions. After unmounting, the image is converted to
read-only compressed UDZO format. Finder or AppleScript is not used by the
build, so no Automation permission is required.

The native verification helper uses the legacy alias API only for Finder
compatibility; the modern bookmark is checked too. Verification resolves both after the final image is
mounted elsewhere, checks the 800 × 650 point background size, and rejects
embedded build-machine user or temporary paths. This process does not depend
on a static alias referring to a developer's checkout.

## Gatekeeper

The default app build uses an ad-hoc signature and is not submitted for Apple
notarization. `CODE_SIGN_IDENTITY` can supply a signing identity to the app build,
but neither build nor packaging commands perform notarization. Do not describe
the default release as Developer ID signed or Apple notarized.

A DMG does not bypass Gatekeeper. GitHub, the visible Finder background and the
standalone HTML guide explain the manual approval process for the installed
app. Nothing removes quarantine attributes, changes Gatekeeper policy, runs an
installation script, or automatically opens the app.

## Verification

`verify-package.py` verifies both release checksums, mounts the DMG read-only
without opening Finder, compares the app with the build byte for byte, verifies
its code signature and Applications shortcut, and resolves its volume-specific
background alias and bookmark. It checks the fixed icon layout, standalone
three-language guide and absence of PKG files. The ZIP app, executable
permissions and code signature are checked too. No app is installed or launched.

App signature integrity does not establish Apple notarization. Actual
first-open Gatekeeper dialogs and drag/replace authorization must be checked
on a downloaded release on a separate Mac. A local Finder screenshot verifies
the presentation independently from the noninteractive build checks.
