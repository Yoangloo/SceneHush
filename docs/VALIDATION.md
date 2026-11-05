# Native-mode validation

Recorded on **2026-11-05** for SceneHush 1.1.0. These results describe one tested setup and capture path, not universal display or agent compatibility.

## Setup

- One Apple Silicon Mac with its built-in display and one external display, both in SDR mode.
- BetterDisplay and the previously installed SceneHush process were quit before the native checks.
- No new permission requests were made, and no desktop screenshots were saved.

## Observed results

| Check | Result |
| --- | --- |
| Unit tests | 22 tests passed. |
| Native `--live-test` | During the three-second test, RGB gamma-table values read back as zero on both displays. Restoration returned both displays to their original RGB tables. |
| Main-process crash | After `SIGKILL` terminated the native test's main CLI process, its independent watchdog restored both displays and cleared the snapshot, without fallback restoration. The entire crash-recovery test completed in 0.66 seconds; this is not a separate measurement of watchdog latency. |
| ScreenCaptureKit | Display captures were compared only within a region occupied by the test's own window. After conversion to sRGB, the before/during mean absolute error was 0 for both display regions, and the before/during ICC profiles matched for each display. Gamma readbacks were zero immediately before and after the 0.067-second capture interval. |

The watchdog check applies to **native mode only**. It does not establish crash recovery for BetterDisplay mode. The capture check establishes the measured result for this ScreenCaptureKit path and test window; it does not establish compatibility with every capture tool or agent.

## Limits

Intel Macs, macOS 13, HDR, virtual displays, DisplayLink, and AirPlay were not tested in actual runtime environments for this record. A universal build or successful gamma readback does not replace those runtime checks.

Native mode uses software gamma dimming. These checks do not show that hardware brightness or the physical backlight reached zero, or that display power was turned off. SceneHush is not a lock screen and does not prevent sleep or guarantee continued agent execution.
