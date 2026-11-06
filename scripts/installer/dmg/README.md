# Finder layout

`generate_layout.py` writes a Finder icon-view layout for each mounted build
volume. `VolumeAssets.m` renders the 800 × 650-point installation background
and creates its native Foundation bookmark. The vendored `mac_alias` helper
creates the legacy alias and parses the bookmark for validation and serialization.
These are build helpers; none is installed in the app or
run when the user opens the DMG. Normal packaging requires no pip install,
network download, Finder scripting or Automation permission.

The image root must use these exact visible filenames:

- `SceneHush.app` at `(210, 165)`.
- `Applications` at `(590, 165)`, a symlink to `/Applications`.
- `Installation Guide.html` at `(400, 550)`.

The window is 800 × 680 points including its title bar, with 96-point icons
and 14-point labels. The 800 × 650-pixel background maps directly to the
content area; Finder ignores PNG DPI metadata, so it is rendered at 1×.
The background shows the drag direction and short English, Chinese and
Japanese steps before the app is opened, including where to allow a blocked
first launch. The standalone HTML guide supplies the full instructions and a
user-initiated settings link. Toolbars, sidebars, tab bars, path bars and status
bars are hidden. These are Finder preferences; a user's Finder may override
them.

The alias and bookmark are generated for the mounted image's own hidden
`.background/background.png`. The bookmark retains native path and volume metadata,
with backing-image locators, extra tables and security-scope data removed;
the legacy alias is retained for Finder compatibility. Volume identity
and `/Volumes/…` paths may appear in these references, but build-machine
`/Users/`, `/private/` and `/tmp/` paths are rejected in UTF-8 and UTF-16. Do not
reuse a layout generated for a different image volume.

## Generation and inspection

`scripts/package.sh` prepares and mounts a writable image without browsing or
opening it, renders the background, and runs the helpers before compressing the
finished image read-only. The helper API is:

```sh
"$VOLUME_ASSETS" bookmark "$IMAGE_VOLUME" "$NATIVE_BOOKMARK"
python3 scripts/installer/dmg/generate_layout.py "$IMAGE_VOLUME" "$BACKGROUND_METADATA" --native-bookmark "$NATIVE_BOOKMARK"
python3 scripts/installer/dmg/generate_layout.py "$IMAGE_VOLUME" "$EXPORTED_METADATA" --check
```

`VOLUME_ASSETS` is the compiled `VolumeAssets.m` helper. Its `bookmark` command
creates the native input; the layout generator sanitizes that record, creates
the legacy alias, writes `.DS_Store`, and exports and validates its metadata.
`--check` only reads `.DS_Store`
from the volume and exports its alias and bookmark to the specified plist.
`VolumeAssets verify` can then resolve both references against the mounted
volume; package verification repeats this after remounting the finished image.
The layout generator itself never mounts an image, controls Finder, installs
or launches an app, or modifies system preferences.

The `.DS_Store`, legacy alias and bookmark parsing helpers are vendored source subsets documented in
[vendor/README.md](vendor/README.md). Finder preference fields follow the
icon-view implementation in `dmgbuild` 1.6.5, `dmgbuild/core.py`; its source is
not included. Real Finder visual verification is performed separately from
the headless packaging process.
