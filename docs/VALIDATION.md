# Validation record

## 1.2.5 — drag installation and installation-specific introduction

Checked on 2026-11-06 on the same Apple Silicon Mac:

- All 41 core tests passed. Nine installation-identity tests cover legacy preferences, completion and relaunch, a same-version new copy, replacement at the same path, an in-place executable overwrite with preserved modification time, same-volume renaming, version/build changes, unreadable metadata, and an incomplete matching marker. Identity uses a persistent volume UUID rather than a device number; an actual operating-system reboot was not performed.
- An isolated GUI harness compiled the current app delegate, introduction/settings views, configuration, installation identity, and localized resources. Twenty startup checks and ten source-binding checks passed. Legacy completion cannot bypass the introduction through `--settings`; closing it keeps corner actions suspended; completion preserves preferences; the same installation retains completion; a replacement or unreadable identity requires introduction again. Display, demonstration, recovery, and hot-corner integrations were replaced with fail-fast stubs: no dimming or system-setting changes occurred, and the real user profile was not used.
- The active, key-window Chinese welcome capture shows the existing introduction UI without truncation. It precedes the final volume-UUID-only identity correction; routing checks were rerun against the final identity source. It is not a capture of a complete downloaded-app installation.
- Universal arm64/x86_64 packaging passed with a macOS 13 deployment target, strict ad-hoc signature verification, and 64 matching nonempty strings in each of English, Simplified Chinese, and Japanese. `python3 scripts/installer/verify-package.py --arch universal` passed on the final 1.2.5 downloads.
- The DMG contains SceneHush.app, an Applications shortcut, and an offline three-language installation guide. Its background gives drag-install and Gatekeeper instructions before the app is opened. Verification checked read-only mounting, app bytes/signature, the exact shortcut destination, image dimensions, background references after conversion and remounting at a different path, ZIP permissions, and both download checksums. No PKG is produced.
- Finder layout was checked in an actual Finder window: the three-language instructions, drag arrow, application icons, and help entry were fully visible. Layout generation uses vendored, unmodified MIT-licensed build helpers with recorded upstream hashes; normal packaging requires no package download. The helper code is not bundled in the app.
- All three README headers now lead with a DMG download, followed by ZIP and release-list links on a separate row. Installation documentation explains the security warning before the first app launch and the introduction shown for a new installation, while retaining existing preferences.

The app remains ad-hoc signed and is not Apple notarized. These checks do not establish the Gatekeeper experience of a quarantined browser download, a real Finder drag-copy, installation on a fresh Mac, Intel runtime, or older macOS Finder appearance. No new display-control or agent-compatibility test was performed. SceneHush does not prevent sleep or automatic locking. Public CI and release-download checks are verified separately.

## 1.2.4 — native installer and completion status

Checked on 2026-11-06 on the same Apple Silicon Mac:

- All 32 core tests passed. The universal arm64/x86_64 app built successfully with a macOS 13 deployment target, passed strict ad-hoc signature verification, and loaded all 64 strings in each of its three languages.
- Three active, key-window captures compiled the current UI and core sources with fake actions. English, Simplified Chinese, and Japanese completion pages show a green check and secondary text, without a capsule background or button action. No text was truncated. These captures performed zero gamma operations and did not change the real user profile.
- `python3 scripts/installer/verify-package.py --arch universal` passed on the final 1.2.4 artifacts. The native Installer distribution contains three localized page sets, permits only the LocalSystem domain, and installs only SceneHush.app into /Applications. Its payload matches the signed build, with no installation scripts, automatic launch, preference files, or security-setting changes. Read-only Installer metadata queries parsed the package successfully.
- The DMG mounted read-only without opening Finder. It contains the matching PKG and offline three-language HTML guide as its two visible entries, plus committed Finder metadata. The ZIP app bytes, executable permissions, signature, and all three download checksums matched the build.
- Opening the locally generated PKG displayed the native Installer welcome page and version 1.2.4. The test stopped there and closed Installer; it did not continue, authenticate, or install. The user-initiated Privacy & Security link opened that pane on this Mac without changing settings. The guide also retains the manual path.
- All three README headers put the language links, main PKG download, and alternative ZIP/DMG/release links on separate rows, with installation help next to the downloads. CI and release workflows now run the archive verification before publishing.

The installer is unsigned and the app has an ad-hoc signature; neither is Apple notarized. Opening a locally generated package does not establish the Gatekeeper experience of a quarantined browser download or another Mac. Administrator installation, Intel runtime, older macOS Installer appearance, physical Finder layout, and a fresh-machine first launch remain untested here. No new display-control or agent compatibility test was performed. Public CI and release downloads are checked separately.

## 1.2.3 — first-run language, branding, and download access

Checked on 2026-11-06 on the same Apple Silicon Mac with two connected displays:

- All 32 core tests passed, including first launch without a configuration, 15 system-language preference cases, and three persisted manual-language cases.
- A separate app harness compiled the actual configuration and localizer sources with the three resource bundles. Ten independent processes used process-only `-AppleLanguages` preferences to check English, Chinese, Japanese, unsupported first choices followed by a supported language, empty/unsupported lists, and saved manual choices. All selected the expected resource language and loaded 64 strings. Neither system defaults nor the real user profile was modified.
- Nineteen active, key-window screenshots covered all five introduction stages in English, Simplified Chinese, and Japanese, the three settings languages, and Chinese dark appearance. They use the final UI, configuration sources, resources, and day/night artwork. Source bindings place icon-only Back before the header spacer and Skip after it, with localized accessibility names and help. Six fake-actions model checks passed; no pointer, keyboard, or Accessibility hit-testing was performed. The demonstration screenshots use simulated progress and do not prove animation or display recovery.
- The persistent native window check passed 60 accepted-frame and minimum-layout checks on both connected displays, without display control. Both displays used 2× scaling; this did not synthesize mouse dragging or test mixed-scale screens.
- The repository artwork, installed 1.2.2 icon, and macOS icon service already agreed on the day/night switch before this change. The new package uses an explicit `SceneHush-DayNight` bundle icon key, and its ICNS bytes match that same source artwork. This is a targeted refresh, not evidence that an old system cache was reproduced.
- Universal arm64/x86_64 packaging, strict ad-hoc signature verification, three-language diagnostics, and local DMG/ZIP checksums passed. The three README download buttons use local SVG artwork and point to the 1.2.3 DMG, with ZIP and release-list links alongside them.

These checks performed no gamma dimming or agent compatibility test. Intel runtime, macOS 13 fallback appearance, mixed-scale displays, and actual pointer hit-testing remain untested here. SceneHush still does not prevent sleep or automatic locking or guarantee continued execution for every agent. Public CI and release downloads are verified separately.

## 1.2.2 — onboarding and cross-display window layout

Checked on 2026-11-06, on the same Apple Silicon Mac with two connected displays:

- All 29 existing core tests passed; universal arm64/x86_64 packaging, strict ad-hoc signature verification, and the three-language diagnostic passed. The resource sets still contain 64 matching nonempty keys.
- Eleven active, key-window captures covered the welcome, permissions, and completion pages in all three languages and Chinese settings in light/dark appearance. The header contains Skip, the footer leads with v1.2.2, and the two primary introduction actions use the shorter localized labels. Menu source inspection confirmed a template sun icon, no introduction menu entry, and the retained settings-page replay action.
- A fake-actions harness verified introduction start, rejection of repeated starts, completion, and cancellation through the actual model. It did not exercise mouse, keyboard, or Accessibility hit-testing, and performed zero gamma operations. The settings screenshots preceded the final minimum-size anchor change; view content and the captured 620×840 size were unchanged by those anchors.
- Comparing native windows exposed SwiftUI measurement changing the old settings minimum and intrinsic size. Settings now disables automatic hosting size propagation and uses stable 560×700 minimum constraints; both hosting views resize with their AppKit window. Only introduction content participates in stage animation.
- A native window harness moved settings and introduction windows between the two connected displays, refreshed all three languages, and switched light/dark appearance. All 90 accepted window frames remained stable after layout settled, and settings fitting size retained its 560×700 minimum. This used programmatic AppKit frame moves, not synthesized physical dragging. Both connected displays used a 2× backing scale, so mixed-scale displays and the user's exact transient flash were not deterministically reproduced.

`scripts/test-window-layout.sh` preserves the focused regression check. Its independent compile and run passed 60 checks on the same two displays. It compiles configuration types and the actual views with fake actions, excluding the display engine and app delegate. It requires a macOS desktop session and can write a JSON report to the supplied path.

## 1.2.1 — interface consistency

Checked on 2026-11-06:

- `make test`: all 29 existing tests passed. No display-control behavior changed in this release.
- Universal arm64/x86_64 packaging and strict ad-hoc signature verification passed with a macOS 13 deployment target. The packaged localization diagnostic passed for English, Simplified Chinese, and Japanese, with 64 matching nonempty keys each.
- A temporary harness compiled the current settings, introduction, shared styles, and localizer with fake actions. Seven actual window captures were active and key: three settings languages, Chinese dark appearance, 560-point width, a 700-point-high window scrolled to its footer, and the introduction permissions page. Both settings actions shared their size, capsule shape, typography, and native material. Control edges aligned, and the localized Star invitation and full repository address remained visible.
- The harness did not construct the app delegate or native gamma controller, used no user preferences, and performed zero gamma operations. The non-key-window comparison was kept separate from the seven active-window checks. Documentation settings images were refreshed from the active captures.

These are local UI and build checks. The original native display and recovery checks below remain historical evidence for the unchanged engine. Intel runtime and macOS 13 fallback appearance were not tested on hardware; public CI and release checks are recorded by GitHub Actions.

## 1.2.0 — local native GUI checks

Recorded on **2026-11-05**, on one Apple Silicon Mac running **macOS 27.2**, with its built-in display and one external display, both in SDR mode. These results cover this setup, not universal display or agent compatibility.

### Method

A native GUI harness compiled the app's `AppDelegate`, `OnboardingWindow`, `DisplayDemonstration`, display engine, and supporting views, with a temporary profile injected to isolate test data. It advanced the actual onboarding model programmatically and exercised native window Escape and close events. It did not automate mouse clicks or Accessibility hit-testing.

The installed app was gracefully stopped before display testing. The harness saved the starting RGB tables, monitored both displays during restoration, and verified original tables at the end. The user's existing preference file was unchanged byte for byte.

### Observed results

| Check | Result |
| --- | --- |
| Unit tests | All 29 tests passed, including configuration migration, native progress, and recovery cases. |
| Introduction flow | Welcome → permissions → demonstration → completion → settings passed through the actual models and controllers. Finishing saved `onboardingCompleted = true` in the temporary profile. |
| Five-second restoration | Both displays reached zero RGB output. The demonstration completed in 5.041 seconds on this setup. Across 51 gamma readback samples, progress and display output were monotonic: the first sample was zero; at 2.505 seconds the measured output scale was 49.07%; the final sampled scale was 99.99%, followed by verified restoration of each display's original RGB table and removal of the snapshot. |
| Escape and cancellation | Native window Escape restored displays. Repeated cancellation was safe, a new start during cancellation was ignored, and repeated window-close requests restored displays. |
| Corner suspension | Corner triggers remained suspended while onboarding was open. This check did not establish mouse-hit behavior after onboarding. |
| Unexpected exit | The harness's main process was terminated with `SIGKILL` during the demonstration. Its armed recovery watchdog restored saved display state, without fallback restoration. |
| UI captures | Three captures of the test's own native UI windows completed without error. The terminal already had capture authorization; no new permission prompt was observed. Capture was performed by the test tooling, not by SceneHush's product flow. |
| Local build and packaging | Universal arm64 + x86_64 builds and DMG/ZIP packaging passed. The bundled app signature and all 62 localization keys per language passed verification. |

The measured output scales describe software RGB gamma tables. They do not establish that physical brightness or the backlight reached zero. The UI captures establish the observed layouts; they do not measure animation frame rate or prove agent capture compatibility during dimming.

### Remaining limits

Public CI and release download checks are recorded separately by GitHub Actions. Intel runtime, macOS 13 fallback controls, HDR, virtual displays, DisplayLink, and AirPlay were not tested in actual runtime environments. Compilation alone does not establish those runtime results.

The 1.1.0 ScreenCaptureKit comparison below is historical evidence from that release. It is not a new capture-compatibility test of 1.2.0, and these checks do not guarantee continued execution for every agent. SceneHush does not prevent sleep or automatic locking and does not provide a lock-screen security boundary.

## 1.1.0 — historical native-mode checks

Recorded on **2026-11-05**. These results describe one tested setup and capture path, not universal display or agent compatibility.

### Setup

- One Apple Silicon Mac with its built-in display and one external display, both in SDR mode.
- BetterDisplay and the previously installed SceneHush process were quit before the native checks.
- No new permission requests were made, and no desktop screenshots were saved.

### Observed results

| Check | Result |
| --- | --- |
| Unit tests | 22 tests passed. |
| Native `--live-test` | During the three-second test, RGB gamma-table values read back as zero on both displays. Restoration returned both displays to their original RGB tables. |
| Main-process crash | After `SIGKILL` terminated the native test's main CLI process, its independent watchdog restored both displays and cleared the snapshot, without fallback restoration. The entire crash-recovery test completed in 0.66 seconds; this is not a separate measurement of watchdog latency. |
| ScreenCaptureKit | Display captures were compared only within a region occupied by the test's own window. After conversion to sRGB, the before/during mean absolute error was 0 for both display regions, and the before/during ICC profiles matched for each display. Gamma readbacks were zero immediately before and after the 0.067-second capture interval. |

The watchdog check applies to **native mode only**. It does not establish crash recovery for BetterDisplay mode. The capture check establishes the measured result for this ScreenCaptureKit path and test window; it does not establish compatibility with every capture tool or agent.

### Limits

Intel Macs, macOS 13, HDR, virtual displays, DisplayLink, and AirPlay were not tested in actual runtime environments for this record. A universal build or successful gamma readback does not replace those runtime checks.

Native mode uses software gamma dimming. These checks do not show that hardware brightness or the physical backlight reached zero, or that display power was turned off. SceneHush is not a lock screen and does not prevent sleep or guarantee continued agent execution.
