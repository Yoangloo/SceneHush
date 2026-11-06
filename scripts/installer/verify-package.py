#!/usr/bin/env python3
"""Inspect release archives without installing, launching, or changing any settings."""

import argparse
import hashlib
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile


PROJECT_ROOT = Path(__file__).resolve().parents[2]
APP_ID = "io.github.yoangloo.SceneHush"
LANGUAGES = ("en", "zh-Hans", "ja")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def run(*arguments):
    result = subprocess.run([str(argument) for argument in arguments], check=False,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        raise RuntimeError("Command failed: " + " ".join(str(argument) for argument in arguments)
                           + "\n" + result.stderr.decode(errors="replace"))
    return result.stdout


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_snapshot(directory):
    result = {}
    for path in sorted(directory.rglob("*")):
        name = path.relative_to(directory).as_posix()
        if path.is_symlink():
            result[name] = ("symlink", os.readlink(path))
        elif path.is_file():
            result[name] = ("file", digest(path), path.stat().st_mode & 0o111)
        elif path.is_dir():
            result[name] = ("directory",)
        else:
            raise ValueError("Unexpected payload file type: " + name)
    return result


def verify_dmg(dmg, app, version, work):
    mountpoint = work / "mounted-dmg"
    mountpoint.mkdir()
    run("hdiutil", "attach", "-readonly", "-nobrowse", "-noautoopen", "-mountpoint", mountpoint, dmg)
    try:
        visible = {path.name for path in mountpoint.iterdir() if not path.name.startswith(".")}
        require(visible == {"SceneHush.app", "Applications", "Installation Guide.html"},
                "Disk image must contain the app, Applications and the standalone guide")
        require((mountpoint / "Applications").is_symlink()
                and os.readlink(mountpoint / "Applications") == "/Applications",
                "Applications shortcut must point to the standard Applications folder")
        require(tree_snapshot(mountpoint / "SceneHush.app") == tree_snapshot(app),
                "DMG app differs from the signed app build")
        run("codesign", "--verify", "--strict", mountpoint / "SceneHush.app")
        require((mountpoint / ".background/background.png").is_file(), "Missing visible installation guidance background")
        layout_script = PROJECT_ROOT / "scripts/installer/dmg/generate_layout.py"
        metadata = work / "background-metadata.plist"
        run("python3", layout_script, mountpoint, metadata, "--check")
        helper = work / "VolumeAssets"
        run("xcrun", "clang", "-fobjc-arc", "-Wno-deprecated-declarations", "-framework", "AppKit",
            "-framework", "CoreServices", PROJECT_ROOT / "scripts/installer/dmg/VolumeAssets.m", "-o", helper)
        run(helper, "verify", mountpoint, metadata)
        guide = (mountpoint / "Installation Guide.html").read_text(encoding="utf-8")
        for language in LANGUAGES:
            require('data-language="' + language + '"' in guide, "Missing installation guide language")
        require(version in guide and ".pkg" not in guide, "Guide must describe this drag-install release")
        require("https://support.apple.com/en-us/102445" in guide, "Missing official Gatekeeper help")
        require("x-apple.systempreferences:" in guide and "Privacy &amp; Security" in guide,
                "Guide needs a settings link and a readable manual path")
        require("<script src=" not in guide and '<link rel="stylesheet"' not in guide,
                "Installation guide must work offline")
        require(not list(mountpoint.rglob("*.pkg")), "Disk image must not include an installer package")
    finally:
        run("hdiutil", "detach", mountpoint)
    print("DMG: app bytes/signature, Applications shortcut, offline three-language guide and resolved background verified")


def verify_zip(archive, app, work):
    with zipfile.ZipFile(archive) as zipped:
        require(zipped.testzip() is None, "ZIP checksum failure")
        for name in zipped.namelist():
            path = Path(name)
            require(not path.is_absolute() and ".." not in path.parts, "Unsafe ZIP member path")
            require(path.parts[0] in {"SceneHush.app", "__MACOSX"}, "Unexpected ZIP payload")
    destination = work / "zip"
    run("ditto", "-x", "-k", archive, destination)
    require(tree_snapshot(destination / "SceneHush.app") == tree_snapshot(app), "ZIP app differs from the signed build")
    run("codesign", "--verify", "--strict", destination / "SceneHush.app")
    print("ZIP: app bytes, executable permissions and signature verified")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--arch", choices=("universal", "arm64", "x86_64"), default="universal")
    parser.add_argument("--app", type=Path, default=PROJECT_ROOT / "build/SceneHush.app")
    parser.add_argument("--release-dir", type=Path, default=PROJECT_ROOT / "dist")
    args = parser.parse_args()
    app = args.app.resolve()
    with (app / "Contents/Info.plist").open("rb") as file:
        info = plistlib.load(file)
    require(info.get("CFBundleIdentifier") == APP_ID, "Unexpected app identity")
    version = info["CFBundleShortVersionString"]
    architectures = {"arm64", "x86_64"} if args.arch == "universal" else {args.arch}
    actual_architectures = set(run("xcrun", "lipo", "-archs", app / "Contents/MacOS/SceneHush").decode().split())
    require(actual_architectures == architectures, "Build architecture does not match requested package")
    name = "SceneHush-" + version + "-" + args.arch
    release = args.release_dir.resolve()
    assets = {extension: release / (name + "." + extension) for extension in ("dmg", "zip")}
    for asset in assets.values():
        require(asset.is_file(), "Missing release asset: " + str(asset))
    checksum_file = release / (name + "-SHA256SUMS.txt")
    checksums = {line.split(maxsplit=1)[1]: line.split(maxsplit=1)[0]
                 for line in checksum_file.read_text().splitlines()}
    require(checksums == {asset.name: digest(asset) for asset in assets.values()}, "Release checksums do not match both downloads")
    with tempfile.TemporaryDirectory(prefix="SceneHush-verify-") as directory:
        work = Path(directory)
        verify_dmg(assets["dmg"], app, version, work)
        verify_zip(assets["zip"], app, work)
    print("App signature integrity verified; this does not establish Apple notarization")
    print("Release " + version + " (" + args.arch + "): all packaging checks passed; nothing installed or launched")


if __name__ == "__main__":
    main()
