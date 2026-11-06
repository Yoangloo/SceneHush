#!/usr/bin/env python3
"""Regenerate the committed Finder layout; never invokes Finder or mounts a disk."""

import argparse
from pathlib import Path

try:
    from ds_store import DSStore
except ImportError as error:
    raise SystemExit(
        "Optional development dependency missing: install ds-store==1.3.1 "
        "and mac-alias==2.2.3 in a temporary virtual environment. "
        "Normal packaging uses the committed layout and needs neither."
    ) from error


DEFAULT_OUTPUT = Path(__file__).with_name("Finder-layout.dsstore")
WINDOW_SETTINGS = {
    "ShowStatusBar": False,
    "WindowBounds": "{{120, 120}, {720, 480}}",
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
    "backgroundType": 1,
    "backgroundColorRed": 0.965,
    "backgroundColorGreen": 0.973,
    "backgroundColorBlue": 0.988,
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
    "Install SceneHush.pkg": (200, 208),
    "Installation Guide.html": (520, 208),
}


def generate(output: Path) -> None:
    with DSStore.open(str(output), "w+") as store:
        store["."]["vSrn"] = ("long", 1)
        store["."]["bwsp"] = WINDOW_SETTINGS
        store["."]["icvp"] = ICON_SETTINGS
        store["."]["icvl"] = ("type", b"icnv")
        for name, location in ICON_LOCATIONS.items():
            store[name]["Iloc"] = location


def verify(output: Path) -> None:
    with DSStore.open(str(output), "r") as store:
        expected_keys = {
            (".", b"vSrn"),
            (".", b"bwsp"),
            (".", b"icvp"),
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
        if store["."]["icvp"] != ICON_SETTINGS:
            raise ValueError("Unexpected Finder icon settings")
        if store["."]["icvl"] != (b"type", b"icnv"):
            raise ValueError("Finder must open in icon view")
        for name, location in ICON_LOCATIONS.items():
            if store[name]["Iloc"] != location:
                raise ValueError(f"Unexpected location for {name}")

    data = output.read_bytes()
    for private_path in ("/Users/", "/Volumes/", "/private/", "/tmp/", "file://"):
        for encoding in ("utf-8", "utf-16-be", "utf-16-le"):
            if private_path.encode(encoding) in data:
                raise ValueError("Finder metadata must not embed a build-machine path")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Validate without writing")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    arguments = parser.parse_args()
    if not arguments.check:
        generate(arguments.output)
    verify(arguments.output)
    print(f"Verified Finder layout: {arguments.output.name}")


if __name__ == "__main__":
    main()
