# Security

## What SceneHush does

SceneHush dims display output through native macOS gamma controls. It does **not** lock the Mac, end a session, hide data from applications, or provide an access-control boundary. There is no authentication: someone nearby can restore the display and operate the unlocked desktop. It does not set hardware brightness to zero or guarantee physical backlight or power-off. Use macOS Lock Screen when the computer must be left securely unattended.

## Permissions and privacy

Display control and corner detection do not require Accessibility, Screen Recording, or administrator permission. SceneHush does not capture the screen or control other applications. Optional launch at login uses macOS's login-item service, which may require the user's approval. Changing a conflicting macOS Hot Corner is a separate, optional choice in the app.

The app has no analytics, telemetry, or background network service. Its preferences, display identifiers, and recovery data are stored locally. Opening the project link is an explicit user action.

## Agent workflows

SceneHush changes display output without sending pause commands to agents or logging out. It can be useful for a short break when leaving the current desktop session unlocked is acceptable. Some workflows depend on an unlocked session or foreground interaction; this does not apply to every agent.

SceneHush does not keep the Mac awake, suppress automatic locking, bypass authentication, or guarantee that an agent continues running or completes a task. Choose the Mac's lock and sleep behavior according to the environment's security requirements.

No black desktop overlay is added, but this does not guarantee behavior for every screen-capture implementation. Validate the actual agent and capture path. HDR, virtual displays, and some drivers may not support native dimming or may override it.

## Display restoration

Original RGB tables are saved before display changes. A watchdog attempts restoration after an unexpected main-app exit, including during the optional introduction demonstration. The five-second fade can be stopped with Escape to restore immediately. Corner triggers are paused while the introduction is open.

Recovery is best effort. A disconnected or unresponsive display may require reconnection. Do not discard an unresolved snapshot as a way to dismiss an error. Restore displays and quit old releases before upgrading; external-app brightness snapshots from old releases are preserved, but must be restored with the previous release before using native dimming.

## Supported versions and reporting

Security fixes target the latest published SceneHush version. Reproduce reports on that version when possible.

Use [GitHub private vulnerability reporting](https://github.com/Yoangloo/SceneHush/security/advisories/new) if available. Otherwise, open a minimal [issue](https://github.com/Yoangloo/SceneHush/issues) asking for a private reporting route, without exploit details or sensitive data.

Include affected SceneHush and macOS versions, display setup, reproduction steps, expected and actual behavior, and security impact. Do not include tokens, credentials, display serial numbers, or a full personal configuration.

## Distribution

The release is ad-hoc signed and is not Apple notarized. Download from this repository's Releases page or build the tagged source. SHA-256 checksums detect a mismatch; they do not establish a Developer ID identity or replace notarization.
