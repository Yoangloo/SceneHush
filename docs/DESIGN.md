# SceneHush interface

The interface serves short breaks while local agents work: supported screens rest while apps and the current desktop session stay in place. Keep that purpose visible in the slogan and introduction. The day/night switch connects the icon, introduction, and display demonstration without adding another concept to learn.

## One continuous journey

1. Welcome: introduce the name, slogan, and one-corner action. Use a direct Get started action.
2. Permissions: explain that display dimming and corner detection need no extra access; distinguish optional launch at login. Start the demonstration only after the user chooses Try it. Place Skip at the top right and an arrow-only Back control at the top left after the welcome step. Keep the arrow's accessibility label and help localized.
3. Demonstration: darken actual display output, then restore saved RGB tables over five seconds. Let the introduction become visible as the displays brighten. Escape and window closing must restore immediately, and the recovery watchdog must cover interruption.
4. Completion: confirm restoration, explain the unlocked-session boundary, and enter settings. The introduction can be replayed from settings; keep it out of the menu bar's action list.

Corner triggers pause while the introduction is open. Display state and preferences remain the same objects throughout the journey; a visual transition must not create a second dimming session or overwrite an original table.

## Visual relationships

- Center the icon, name, and short slogan as one brand group. Keep ordinary settings smaller so the identity does not compete with controls.
- Align labels and control edges across rows. Separate behavior from preferences with spacing and restrained surfaces rather than giving each setting a card.
- Use the system font, one cool accent, and a warm/cool day/night palette. The fine background pattern stays behind content and accepts no input.
- Use native Liquid Glass button styles on macOS 26+. Older systems use bordered native controls and material surfaces. Respect Reduce Transparency for surfaces and Reduce Motion for decorative transitions.
- Action buttons share a capsule shape, height, and type scale across settings and the introduction. The two settings actions have equal sizing and matching visual treatment, including in light and dark appearances.
- Place the repository address and a short, localized invitation to leave a GitHub Star at the bottom of settings. Keep this support link visually separate from display controls.
- Use a small sun as the menu bar icon, distinct from macOS Control Center. Keep it icon only and show the app name inside its menu. Preserve native keyboard focus, accessible labels, and all four corner choices.
- Anchor the introduction's version at the bottom left and its language selector at the bottom right, keeping navigation at the top.
- Let AppKit own window frames and minimum sizes. Disable automatic SwiftUI hosting-size constraints and autoresize hosted content within the window; limit introduction animations to the content region so display changes do not animate window geometry.

## Copy and motion

English, Simplified Chinese, and Japanese share meaning and hierarchy. Lead with local agents and the preserved desktop session. Reassure users that SceneHush only changes display output and does not pause applications, without promising that every agent keeps running. The completed introduction separately explains sleep, automatic locking, and the absence of authentication; SceneHush provides no keepalive or sleep-prevention feature.

Small UI changes use brief fades. The five-second restoration is an intentional, optional display demonstration; it is not a loading delay. Test cancellation, repeated starts, and failure cleanup as part of the animation. A screenshot establishes layout only, not smoothness or recovery.

Visual study informed the hierarchy, row alignment, and continuity of the journey. Reference artwork is not included in the app; the day/night icon is generated from the project's own drawing source.
