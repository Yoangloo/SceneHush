# Finder layout

`Finder-layout.dsstore` is a committed, volume-independent Finder icon-view
template. Packaging copies it to `.DS_Store` at the disk image root. Using the
template adds no Python package or other third-party runtime dependency.

The image root must use these exact visible filenames:

- `Install SceneHush.pkg` at `(200, 208)`.
- `Installation Guide.html` at `(520, 208)`.

The window is 720 × 480 points, with 96-point icons, 14-point labels and a pale
blue background. Toolbars, sidebars, tab bars, path bars and status bars are
hidden. An optional license should be named `.LICENSE.txt` so it does not become
an unpositioned third icon. These are Finder preferences; a user's Finder may
override them.

A solid background deliberately avoids image aliases and bookmarks. Those
records normally refer to a particular mounted volume and are unsuitable for
this reusable static template. The layout contains no volume name, UUID,
absolute path, network URL, application launch action or installer script.

## Optional regeneration

From the repository root, use an isolated temporary virtual environment:

```sh
python3 -m venv /tmp/scenehush-layout-venv
/tmp/scenehush-layout-venv/bin/python -m pip install ds-store==1.3.1 mac-alias==2.2.3
/tmp/scenehush-layout-venv/bin/python scripts/installer/dmg/generate_layout.py
/tmp/scenehush-layout-venv/bin/python scripts/installer/dmg/generate_layout.py --check
```

The generator validates every stored setting and scans for build-machine paths.
It does not mount a disk, control Finder, install or launch anything, or modify
system preferences. Its `.DS_Store` mapping API comes from
[`ds_store` 1.3.1](https://pypi.org/project/ds-store/1.3.1/). The Finder
preference keys follow the icon-view implementation of
[`dmgbuild` 1.6.5](https://pypi.org/project/dmgbuild/1.6.5/), in `dmgbuild/core.py`.
Both projects use the MIT license. No third-party implementation is bundled
with this project; only the generated Finder metadata is shipped.
