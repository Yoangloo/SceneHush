# Offline Finder metadata helpers

The following unmodified upstream source subsets are included only for building
and inspecting release disk images:

- [`ds_store` 1.3.1](https://pypi.org/project/ds-store/1.3.1/): `ds_store/__init__.py`, `buddy.py`, `store.py`. Upstream: [dmgbuild/ds_store](https://github.com/dmgbuild/ds_store). Complete MIT license and copyright: `LICENSE.ds-store`. Original file hashes: `UPSTREAM-SHA256SUMS.txt`.
- [`mac_alias` 2.2.3](https://pypi.org/project/mac-alias/2.2.3/): `mac_alias/__init__.py`, `alias.py`, `bookmark.py`, `osx.py`, `utils.py`. Upstream: [dmgbuild/mac_alias](https://github.com/dmgbuild/mac_alias). Complete MIT license and copyright: `LICENSE.mac-alias`. Original file hashes: `UPSTREAM-mac-alias-SHA256SUMS.txt`.

No upstream code is modified. Command-line entry points, package metadata and
other unused files are omitted. The hashes can be checked from this directory
with `shasum -a 256 -c` against each manifest. Normal packaging requires no pip
installation or network access.

`generate_layout.py` uses the same Alias/Bookmark APIs as `dmgbuild` 1.6.5. The
bookmark records only a volume UUID and a path relative to that volume, without
a locator for the developer's temporary writable image. Structural validation
rejects extra bookmark tables, backing-image locators, private build paths and
user identity. Apple's frameworks separately verify that both references
resolve inside the final mounted volume.

These Python sources are not copied into SceneHush.app. They do not run when a
user opens or installs the release. Updating them requires reviewing upstream
changes and licenses and recalculating the original source-file hashes.
