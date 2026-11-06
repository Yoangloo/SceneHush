# Native macOS installer

`scripts/package.sh` builds a standard macOS Installer product (`.pkg`), a DMG
containing that same installer and a standalone installation guide, and a ZIP
for manual app installation. All three downloads are covered by SHA-256 sums.

```sh
scripts/package.sh --arch universal
python3 scripts/installer/verify-package.py --arch universal
```

Packaging requires macOS, Xcode command line tools, and Python 3.9 or later.
It uses only Apple's packaging tools and the Python standard library. The
optional development dependencies for regenerating Finder metadata are
documented in [dmg/README.md](dmg/README.md); ordinary packaging does not use
or download them.

## Installation behavior

The component payload contains only `SceneHush.app` and installs into
`/Applications`. Apple's standard Installer can request administrator
authentication for that location. The payload has no install scripts,
auto-launch action, login item, display setting changes or preference files.
Existing SceneHush preferences are outside the payload and are preserved.
Bundle relocation is disabled so another copy on a mounted DMG or in Downloads
cannot become the installation destination. Version and bundle identity checks
are enabled.

Restore the displays and quit an older SceneHush before updating; the installer
does not force quit a running app. Open the installed app manually afterwards.

The Installer introduction, read-me and conclusion are localized in English,
Simplified Chinese and Japanese. The standalone HTML guide uses the browser's
preferred supported language and also has manual language buttons. It embeds
its icon and styling, so installation and Gatekeeper instructions can be read
offline, before either the installer or app is allowed to open.

## Gatekeeper

This packaging script produces an unsigned installer. The normal app build
uses an ad-hoc signature unless `CODE_SIGN_IDENTITY` is supplied to the build
script. Neither command submits software for Apple notarization. Do not label
these packages as Developer ID signed or Apple notarized.

An unsigned package can itself be blocked before its embedded introduction is
visible. GitHub installation instructions and the DMG's separate HTML guide
therefore explain the same manual **System Settings > Privacy & Security >
Open Anyway** flow for both the installer and the app. The guide includes a
user-initiated settings link, a readable manual path, and
[Apple's official instructions](https://support.apple.com/en-us/102445).
Nothing removes quarantine attributes or changes Gatekeeper policy.

## Verification

`verify-package.py` expands the package into a temporary directory, checks its
native Installer metadata using read-only query modes, compares the payload
with the signed build, checks all three Installer languages, and verifies the
checksums. It also mounts the DMG read-only without opening Finder and verifies
the two visible files and committed layout, then checks the ZIP app bytes,
permissions and signature. It never performs an installation or opens the app.

The expected unsigned installer status is reported explicitly. Code signature
verification of the app establishes integrity, not Apple notarization. Actual
first-run Gatekeeper dialogs and authorization behavior must be checked on a
downloaded release on a separate Mac; they are not simulated by this script.
