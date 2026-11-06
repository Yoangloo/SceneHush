# Offline Finder metadata helpers

The following unmodified upstream source subsets are included only for building
and inspecting release disk images:

- [`ds_store` 1.3.1](https://pypi.org/project/ds-store/1.3.1/): `ds_store/__init__.py`, `buddy.py`, `store.py`. Upstream: [dmgbuild/ds_store](https://github.com/dmgbuild/ds_store). Complete MIT license and copyright: `LICENSE.ds-store`. Original file hashes: `UPSTREAM-SHA256SUMS.txt`.
- [`mac_alias` 2.2.3](https://pypi.org/project/mac-alias/2.2.3/): `mac_alias/__init__.py`, `alias.py`, `bookmark.py`, `osx.py`, `utils.py`. Upstream: [dmgbuild/mac_alias](https://github.com/dmgbuild/mac_alias). Complete MIT license and copyright: `LICENSE.mac-alias`. Original file hashes: `UPSTREAM-mac-alias-SHA256SUMS.txt`.

No upstream code is modified. Command-line entry points, package metadata and
other unused files are omitted. The hashes can be checked from this directory
with `shasum -a 256 -c` against each manifest. Normal packaging requires no pip
installation or network access.

`generate_layout.py` uses these helpers for DS_Store records, legacy Alias
creation, and bookmark parsing and serialization. Apple Foundation creates the
native bookmark; the wrapper preserves its path and volume metadata while
removing backing-image locators, extra tables and security-scope data. Any
identity fields are anonymized. Structural validation rejects private build
paths and unexpected metadata. Apple's frameworks separately verify that both references
resolve inside the final mounted volume.

These Python sources are not copied into SceneHush.app. They do not run when a
user opens or installs the release. Updating them requires reviewing upstream
changes and licenses and recalculating the original source-file hashes.
