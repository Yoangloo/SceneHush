# Changelog

Changes are grouped by release. Dates use the release's calendar date.

## 1.2.1 — 2026-11-06

### Changed

- Give action buttons a shared capsule shape, height, and typography across settings and the introduction. Use equal sizing and matching treatment for the two settings actions.
- Add the visible GitHub repository address and a localized invitation to leave a Star at the bottom of settings.
- Extend English, Simplified Chinese, and Japanese resources for the support link and its accessible label.

## 1.2.0 — 2026-11-05

### Added

- A first-run introduction explaining permissions, with an optional all-display dark-to-light demonstration that restores saved RGB tables over five seconds.
- Immediate restoration with Escape during the demonstration, introduction replay, and paused corner triggers while the introduction is open.
- A day/night switch icon, centered name and slogan, aligned settings, a subtle background, and native Liquid Glass controls on macOS 26+, with fallback controls on earlier systems.
- English, Simplified Chinese, and Japanese guidance for the introduction and permission requirements.

### Changed

- Use native macOS display control exclusively; remove BetterDisplay integration and the dimming-method selector.
- Preserve existing corner, restoration, and language preferences, and ignore the removed dimming-method field.
- Extend saved-state restoration to gradual display output changes; a recovery watchdog also covers the introduction demonstration.
- Preserve old external-app brightness files and prevent new dimming while one is pending, so users can restore it with the previous release first.
- Clarify that display control needs no Accessibility, Screen Recording, or administrator permission; launch at login remains optional and may need approval.

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
