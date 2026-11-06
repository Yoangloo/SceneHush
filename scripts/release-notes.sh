#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="${1:-1.2.2}"
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Version must have the form 1.2.2.\n' >&2
  exit 2
fi
NOTES_PATH="$PROJECT_ROOT/docs/RELEASE_NOTES.md"
if [[ ! -f "$NOTES_PATH" ]]; then
  printf 'Release notes are missing.\n' >&2
  exit 1
fi
IFS= read -r NOTES_TITLE < "$NOTES_PATH"
case "$NOTES_TITLE" in
  '# SceneHush '*) ;;
  *) printf 'Release notes must begin with a SceneHush version heading.\n' >&2; exit 1 ;;
esac
printf '# SceneHush %s\n' "$APP_VERSION"
tail -n +2 "$NOTES_PATH"
