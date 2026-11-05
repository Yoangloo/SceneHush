# Changelog

Changes are grouped by release. Dates use the release's calendar date.

## 1.1.0 — 2026-11-05

### Added

- Standalone native dimming through macOS CoreGraphics gamma controls, without BetterDisplay or a desktop overlay.
- A dimming-method selector, with BetterDisplay available as an optional compatibility mode.
- Native display-state snapshots and recovery, with rollback when dimming reports a failure.
- English, Simplified Chinese, and Japanese guidance for native-mode compatibility and hardware-brightness limits.

### Changed

- Use native mode by default, including when an older configuration has no dimming-method setting.
- Make BetterDisplay installation and command-line integration necessary only for its optional mode.
- Clarify that native mode darkens display output without setting the hardware brightness slider to zero or guaranteeing backlight or power-off.

## 1.0.1 — 2026-11-05

### Changed

- Show only the SceneHush icon in the menu bar; the app name appears inside the opened menu.

## 1.0.0 — 2026-11-05

### Added

- SceneHush menu bar app for dimming connected supported displays through BetterDisplay.
- Selection of any of the four screen corners.
- Restore-on-exit behavior by default, with restore-on-next-entry as an option.
- English, Simplified Chinese, and Japanese interfaces, with immediate language switching.
- Optional launch at login through macOS's login-item service.
- Local brightness snapshots and recovery after interruption.
- Optional replacement, backup, and explicit restoration of conflicting macOS Hot Corners.
- Guidance when BetterDisplay or its command-line integration is unavailable.
- Universal macOS app packaging for Apple Silicon and Intel, with DMG/ZIP distribution and source build instructions.

### Distribution notes

- Requires macOS 13 or later and a separately installed, running BetterDisplay.
- Initial binaries are ad-hoc signed, without Developer ID signing or Apple notarization.
- Brightness control does not lock macOS or guarantee physical display power-off.
