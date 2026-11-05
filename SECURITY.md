# Security

## What SceneHush does

SceneHush dims display output through native macOS gamma controls by default. BetterDisplay is an optional compatibility mode. It does **not** lock the Mac, end a session, hide data from applications, or provide an access-control boundary. There is no authentication: another person can restore the display and operate the unlocked desktop. Native mode does not set hardware brightness to zero, and neither mode guarantees physical backlight or power-off. Use macOS's Lock Screen in public or shared environments, or when the Mac must be left securely unattended.

## Agent workflows

SceneHush is useful for short breaks when a computer agent has work in progress and leaving the current desktop session unlocked is acceptable. Some workflows depend on desktop visibility, an unlocked session, or foreground interaction and can be interrupted by locking, sleeping, or pausing that interaction. This does not apply to every agent.

SceneHush does not keep the Mac awake, suppress automatic locking, bypass authentication, or guarantee that any agent continues running or completes a task. Choose the Mac's lock and sleep behavior according to the security requirements of the environment.

Native mode adds no desktop overlay, but that is not a guarantee about every screen-capture implementation. Validate the actual agent and capture workflow in your environment. HDR, virtual displays, and some drivers may not support native dimming or may override it.

The app has no analytics, telemetry, or background network service. Its settings and display recovery data are stored locally. BetterDisplay, when selected, is a separate dependency with its own security and update process.

## Supported versions

Security fixes are made for the latest published version of SceneHush. Please reproduce reports on that version when possible.

## Reporting

For vulnerabilities, use [GitHub's private vulnerability reporting page](https://github.com/Yoangloo/SceneHush/security/advisories/new) if it is available for this repository. If private reporting is unavailable, open a minimal [issue](https://github.com/Yoangloo/SceneHush/issues) asking for a private reporting route, without publishing exploit details or sensitive data.

Include the affected SceneHush and macOS versions, selected dimming method, display setup, steps to reproduce, expected and actual behavior, and security impact. Include the BetterDisplay version only if that mode is used. Do not include access tokens, credentials, or a full copy of your personal configuration.

## Distribution

The current release is ad-hoc signed and is not Apple notarized. Download from this repository's official Releases page or build from the tagged source. SHA-256 checksums can detect a file mismatch; they do not establish a Developer ID identity or replace notarization.
