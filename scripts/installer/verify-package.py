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
PACKAGE_ID = "io.github.yoangloo.SceneHush.pkg"
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


def verify_package(package, app, version, architectures, work):
    expanded = work / "expanded"
    run("pkgutil", "--expand-full", package, expanded)
    distribution = ET.parse(expanded / "Distribution").getroot()
    require(distribution.tag == "installer-gui-script", "Expected a native Installer distribution")
    options = distribution.find("options")
    require(options is not None and options.get("require-scripts") == "false", "Installer must not need scripts")
    require(set(options.get("hostArchitectures", "").split(",")) == architectures, "Installer architecture mismatch")
    domains = distribution.find("domains")
    require(domains is not None and domains.attrib == {
        "enable_localSystem": "true", "enable_currentUserHome": "false", "enable_anywhere": "false"
    }, "Installer must use the standard Applications domain")
    minimum_os = distribution.find("./volume-check/allowed-os-versions/os-version")
    require(minimum_os is not None and minimum_os.get("min") == "13.0", "Incorrect minimum macOS version")
    require(not distribution.findall(".//script"), "Installer must not contain executable scripts")
    require("system.run" not in ET.tostring(distribution, encoding="unicode"), "Installer must not execute commands")
    references = [reference for reference in distribution.findall("pkg-ref") if reference.text and reference.text.strip()]
    require(len(references) == 1 and references[0].get("id") == PACKAGE_ID
            and references[0].get("version") == version
            and references[0].get("onConclusion") == "none", "Incorrect component package or completion action")
    for page in ("welcome", "readme", "conclusion"):
        element = distribution.find(page)
        require(element is not None and element.get("file") == page + ".html", "Missing Installer page: " + page)
        for language in LANGUAGES:
            resource = expanded / "Resources" / (language + ".lproj") / (page + ".html")
            require(resource.is_file() and version in resource.read_text(), "Missing localized Installer resource: " + str(resource))
    for language in LANGUAGES:
        readme = (expanded / "Resources" / (language + ".lproj") / "readme.html").read_text()
        conclusion = (expanded / "Resources" / (language + ".lproj") / "conclusion.html").read_text()
        require(".pkg" in readme and ".pkg" in conclusion, "Gatekeeper guidance must cover the installer itself")

    components = list(expanded.glob("*.pkg"))
    require(len(components) == 1, "Unexpected extra component packages")
    component = components[0]
    info = ET.parse(component / "PackageInfo").getroot()
    require(info.get("identifier") == PACKAGE_ID and info.get("version") == version, "Component identity mismatch")
    require(info.get("install-location") == "/Applications", "Payload must install only into /Applications")
    require(info.get("relocatable") == "false", "App must not relocate to a temporary or previous copy")
    require(info.get("postinstall-action") == "none" and not info.findall(".//scripts"), "Unexpected installation action")
    require(info.find("./strict-identifier/bundle[@id='" + APP_ID + "']") is not None, "Missing strict app identity check")
    require(info.find("./bundle-version/bundle[@id='" + APP_ID + "']") is not None, "Missing app version check")
    require(info.find("./upgrade-bundle/bundle[@id='" + APP_ID + "']") is not None, "App must support a clean first installation and upgrade")
    require(not list(info.find("relocate")), "Unexpected bundle relocation rules")
    require(not any(path.name.lower() == "scripts" for path in expanded.rglob("*")), "Unexpected install scripts archive")
    payload = component / "Payload"
    require({path.name for path in payload.iterdir()} == {"SceneHush.app"}, "Payload must not contain preferences, launch agents, or other files")
    packaged_app = payload / "SceneHush.app"
    require(tree_snapshot(packaged_app) == tree_snapshot(app), "Installer payload differs from the signed app build")
    run("codesign", "--verify", "--strict", packaged_app)

    # These installer modes read metadata; neither performs an installation.
    choices = plistlib.loads(run("installer", "-showChoicesXML", "-pkg", package, "-target", "/"))
    require(bool(choices), "Installer cannot read the distribution choices")
    domains_output = run("installer", "-dominfo", "-pkg", package).decode().strip()
    require(domains_output == "LocalSystem", "Unexpected Installer destination domains")
    signature = subprocess.run(["pkgutil", "--check-signature", str(package)],
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False,
                               env={**os.environ, "LC_ALL": "C"})
    if signature.returncode == 1 and "Status: no signature" in signature.stdout.decode():
        print("PKG signature: unsigned (expected for this release; Gatekeeper may block opening)")
    else:
        require(signature.returncode == 0, "Invalid installer signature")
        print("PKG signature: validated by pkgutil; notarization is not established by this check")
    print("PKG: native Installer metadata, three languages, app-only /Applications payload and signature verified")


def verify_dmg(dmg, package, work):
    mountpoint = work / "mounted-dmg"
    mountpoint.mkdir()
    run("hdiutil", "attach", "-readonly", "-nobrowse", "-noautoopen", "-mountpoint", mountpoint, dmg)
    try:
        visible = {path.name for path in mountpoint.iterdir() if not path.name.startswith(".")}
        require(visible == {"Install SceneHush.pkg", "Installation Guide.html"}, "Unexpected visible disk image contents")
        require(digest(mountpoint / "Install SceneHush.pkg") == digest(package), "DMG installer differs from the standalone download")
        layout = PROJECT_ROOT / "scripts/installer/dmg/Finder-layout.dsstore"
        require((mountpoint / ".DS_Store").read_bytes() == layout.read_bytes(), "DMG has no fixed Finder layout")
        guide = (mountpoint / "Installation Guide.html").read_text()
        for language in LANGUAGES:
            require('data-language="' + language + '"' in guide, "Missing installation guide language")
        require("https://support.apple.com/en-us/102445" in guide, "Missing official Gatekeeper help")
        require("x-apple.systempreferences:" in guide and "Privacy &amp; Security" in guide,
                "Guide needs a settings link and a readable manual path")
        require("<script src=" not in guide and '<link rel="stylesheet"' not in guide,
                "Installation guide must work offline")
    finally:
        run("hdiutil", "detach", mountpoint)
    print("DMG: matching installer, offline three-language guide and fixed layout verified (read-only mount)")


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
    assets = {extension: release / (name + "." + extension) for extension in ("pkg", "dmg", "zip")}
    for asset in assets.values():
        require(asset.is_file(), "Missing release asset: " + str(asset))
    checksum_file = release / (name + "-SHA256SUMS.txt")
    checksums = {line.split(maxsplit=1)[1]: line.split(maxsplit=1)[0]
                 for line in checksum_file.read_text().splitlines()}
    require(checksums == {asset.name: digest(asset) for asset in assets.values()}, "Release checksums do not match all three downloads")
    with tempfile.TemporaryDirectory(prefix="SceneHush-verify-") as directory:
        work = Path(directory)
        verify_package(assets["pkg"], app, version, architectures, work)
        verify_dmg(assets["dmg"], assets["pkg"], work)
        verify_zip(assets["zip"], app, work)
    print("Release " + version + " (" + args.arch + "): all packaging checks passed; nothing installed or launched")


if __name__ == "__main__":
    main()
