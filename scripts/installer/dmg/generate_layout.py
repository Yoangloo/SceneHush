#!/usr/bin/env python3
"""Write or inspect a volume's Finder layout without controlling Finder."""

import argparse
from pathlib import Path
import plistlib
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).with_name("vendor")))
from ds_store import DSStore
from mac_alias import Alias, Bookmark
from mac_alias import bookmark as bookmark_format


WINDOW_SETTINGS = {
    "ShowStatusBar": False,
    "WindowBounds": "{{120, 100}, {800, 680}}",
    "ContainerShowSidebar": False,
    "PreviewPaneVisibility": False,
    "SidebarWidth": 0,
    "ShowTabView": False,
    "ShowToolbar": False,
    "ShowPathbar": False,
    "ShowSidebar": False,
}
ICON_SETTINGS = {
    "viewOptionsVersion": 1,
    "backgroundType": 2,
    "backgroundColorRed": 1.0,
    "backgroundColorGreen": 1.0,
    "backgroundColorBlue": 1.0,
    "gridOffsetX": 0.0,
    "gridOffsetY": 0.0,
    "gridSpacing": 100.0,
    "arrangeBy": "none",
    "showIconPreview": True,
    "showItemInfo": False,
    "labelOnBottom": True,
    "textSize": 14.0,
    "iconSize": 96.0,
    "scrollPositionX": 0.0,
    "scrollPositionY": 0.0,
}
ICON_LOCATIONS = {
    "SceneHush.app": (210, 165),
    "Applications": (590, 165),
    "Installation Guide.html": (400, 550),
}


def check_metadata(metadata, volume=None):
    if set(metadata) != {"alias", "bookmark"}:
        raise ValueError("Expected native background alias and bookmark data")
    for name, data in metadata.items():
        if not isinstance(data, bytes) or not data:
            raise ValueError("Missing native background " + name)
        for private_path in ("/Users/", "/private/", "/tmp/"):
            for encoding in ("utf-8", "utf-16-be", "utf-16-le"):
                if private_path.encode(encoding) in data:
                    raise ValueError("Background metadata must not embed a host-machine path")
    bookmark = Bookmark.from_bytes(metadata["bookmark"])
    if len(bookmark.tocs) != 1 or bookmark.tocs[0][0] != 1:
        raise ValueError("Background bookmark must have only its own volume reference")
    toc = bookmark.tocs[0][1]
    if any(key in toc for key in (0x2040, 0xF080, 0xF081)):
        raise ValueError("Background bookmark must not contain backing-image locators or security scopes")
    if toc.get(bookmark_format.kBookmarkPath) != [".background", "background.png"]:
        raise ValueError("Background must be a relative path inside the image volume")
    volume_path = toc[bookmark_format.kBookmarkVolumePath]
    if Path(volume_path).parent != Path("/Volumes"):
        raise ValueError("Background reference must describe a mounted image volume")
    if toc[bookmark_format.kBookmarkVolumeURL].absolute != "file://" + volume_path:
        raise ValueError("Background volume URL mismatch")
    if toc[bookmark_format.kBookmarkUserName] != "unknown" or toc[bookmark_format.kBookmarkUID] != 99:
        raise ValueError("Background bookmark must not record a user's identity")
    alias = Alias.from_bytes(metadata["alias"])
    normalize = lambda value: value.decode("utf-8") if isinstance(value, bytes) else value
    if alias.volume.disk_image_alias is not None or normalize(alias.volume.posix_path) != volume_path:
        raise ValueError("Background alias must not reference a backing image")
    if normalize(alias.target.posix_path) != "/.background/background.png":
        raise ValueError("Background alias points outside its image volume")
    if volume is not None:
        result = subprocess.run(["diskutil", "info", "-plist", str(volume)], check=True, stdout=subprocess.PIPE)
        information = plistlib.loads(result.stdout)
        if toc[bookmark_format.kBookmarkVolumeName] != information["VolumeName"]:
            raise ValueError("Background volume name mismatch")
        if toc[bookmark_format.kBookmarkVolumeUUID].upper() != information["VolumeUUID"].upper():
            raise ValueError("Background bookmark volume UUID mismatch")


def write_layout(volume: Path, metadata) -> None:
    check_metadata(metadata, volume)
    settings = {**ICON_SETTINGS, "backgroundImageAlias": metadata["alias"]}
    with DSStore.open(str(volume / ".DS_Store"), "w+") as store:
        store["."]["vSrn"] = ("long", 1)
        store["."]["bwsp"] = WINDOW_SETTINGS
        store["."]["icvp"] = settings
        store["."]["pBBk"] = Bookmark.from_bytes(metadata["bookmark"])
        store["."]["icvl"] = ("type", b"icnv")
        for name, location in ICON_LOCATIONS.items():
            store[name]["Iloc"] = location


def inspect_layout(volume: Path):
    with DSStore.open(str(volume / ".DS_Store"), "r") as store:
        expected_keys = {
            (".", b"vSrn"),
            (".", b"bwsp"),
            (".", b"icvp"),
            (".", b"pBBk"),
            (".", b"icvl"),
            *((name, b"Iloc") for name in ICON_LOCATIONS),
        }
        actual_keys = {(entry.filename, entry.code) for entry in store}
        if actual_keys != expected_keys:
            raise ValueError(f"Unexpected Finder records: {actual_keys ^ expected_keys}")
        if store["."]["vSrn"] != (b"long", 1):
            raise ValueError("Unexpected Finder settings version")
        if store["."]["bwsp"] != WINDOW_SETTINGS:
            raise ValueError("Unexpected Finder window settings")
        settings = dict(store["."]["icvp"])
        alias = settings.pop("backgroundImageAlias", None)
        if settings != ICON_SETTINGS:
            raise ValueError("Unexpected Finder icon settings")
        if store["."]["icvl"] != (b"type", b"icnv"):
            raise ValueError("Finder must open in icon view")
        for name, location in ICON_LOCATIONS.items():
            if store[name]["Iloc"] != location:
                raise ValueError(f"Unexpected location for {name}")

        bookmark = store["."]["pBBk"]
        if not isinstance(bookmark, Bookmark):
            raise ValueError("Expected native background bookmark data")
    metadata = {"alias": alias, "bookmark": bookmark.to_bytes()}
    check_metadata(metadata, volume)
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("volume", type=Path, help="Mounted image root")
    parser.add_argument("metadata", type=Path, help="Native background metadata plist; exported after checking")
    parser.add_argument("--check", action="store_true", help="Read the layout without modifying the volume")
    arguments = parser.parse_args()
    if not arguments.check:
        background = arguments.volume / ".background/background.png"
        metadata = {"alias": Alias.for_file(str(background)).to_bytes(),
                    "bookmark": Bookmark.for_file(str(background)).to_bytes()}
        write_layout(arguments.volume, metadata)
    metadata = inspect_layout(arguments.volume)
    with arguments.metadata.open("wb") as file:
        plistlib.dump(metadata, file)
    print("Finder layout and volume-specific background metadata verified")


if __name__ == "__main__":
    main()
