# Validation record

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
