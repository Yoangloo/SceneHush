#!/bin/bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

macos_version="$(sw_vers -productVersion)"
swift_version="$(swift --version 2>&1)"
if (( ${macos_version%%.*} < 14 )) \
  || [[ ! "$swift_version" =~ Swift\ version\ ([0-9]+) ]] \
  || (( BASH_REMATCH[1] < 6 )); then
  printf '%s\n' 'Core tests require macOS 14+ and Swift 6+. The app supports macOS 13+.' >&2
  exit 1
fi

developer_dir="$(xcode-select -p)"
frameworks_dir="$developer_dir/Library/Developer/Frameworks"
testing_plugin="$developer_dir/usr/lib/swift/host/plugins/testing/libTestingMacros.dylib"

# Some standalone CLT releases omit these installed paths from SwiftPM discovery.
if [[ -d "$frameworks_dir/Testing.framework" && -f "$testing_plugin" ]]; then
  exec swift test --build-system native --enable-swift-testing --disable-xctest \
    -Xswiftc -F -Xswiftc "$frameworks_dir" \
    -Xswiftc -load-plugin-library -Xswiftc "$testing_plugin" \
    -Xlinker -F -Xlinker "$frameworks_dir" \
    -Xlinker -rpath -Xlinker "$frameworks_dir" "$@"
fi

exec swift test --enable-swift-testing --disable-xctest "$@"
