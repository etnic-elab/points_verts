#!/usr/bin/env bash
#
# Builds a release with freshly generated launcher icons and splash screens.
#
#     tool/release.sh ios      [extra flutter build args]
#     tool/release.sh android  [extra flutter build args]
#
# On Windows, run it from Git Bash: `bash tool/release.sh android`.
#
# The generated icons and splash images are gitignored, so whatever happens to
# be on disk is what ships. Version 1.7.1 went to the App Store with the 2025
# icon because the archive was cut on a machine that had never run the
# generator against the new config. This script makes regenerating part of
# building, so that can't be forgotten.
#
# It can't make the *sources* current: assets/launcher_icons/ comes from the
# points_verts_assets repo. When that repo is checked out next to this one, the
# masters are compared against it and the build stops if they differ.

set -euo pipefail

usage() {
  echo "usage: $0 <ios|android> [extra flutter build args]" >&2
  exit 2
}

[ $# -ge 1 ] || usage
PLATFORM="$1"
shift

case "$PLATFORM" in
  ios)
    [ "$(uname -s)" = "Darwin" ] || { echo "error: iOS builds need macOS." >&2; exit 1; }
    BUILD=(flutter build ipa "$@")
    ;;
  android)
    BUILD=(flutter build appbundle "$@")
    ;;
  *) usage ;;
esac

cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

step "Checking icon sources"
# Every master the generator reads, taken from its own config so the two can't
# disagree.
masters=$(grep -o 'assets/launcher_icons/[^"]*' flutter_launcher_icons.yaml | sort -u)
ASSETS_REPO="../points_verts_assets"
for master in $masters; do
  if [ ! -f "$master" ]; then
    echo "error: $master is missing. Copy assets/launcher_icons/ from points_verts_assets." >&2
    exit 1
  fi
  if [ -d "$ASSETS_REPO" ] && ! cmp -s "$master" "$ASSETS_REPO/$master"; then
    echo "error: $master differs from $ASSETS_REPO/$master." >&2
    echo "       Pull points_verts_assets and copy assets/launcher_icons/ across." >&2
    exit 1
  fi
done
if [ -d "$ASSETS_REPO" ]; then
  echo "Masters match $ASSETS_REPO (make sure it is pulled)."
else
  echo "warning: $ASSETS_REPO not found, so the masters can't be checked for staleness." >&2
fi

tracked_before=$(git status --porcelain --untracked-files=no)

step "Fetching packages"
flutter pub get

step "Generating splash screens"
dart run flutter_native_splash:create

step "Generating launcher icons"
dart run flutter_launcher_icons

if [ "$PLATFORM" = "ios" ]; then
  step "Verifying iOS icons"
  # Same check as the Xcode build phase; running it here fails before the
  # (much slower) build starts.
  SRCROOT="$PWD/ios" CONFIGURATION=Release sh ios/Scripts/verify_app_icons.sh
fi

# The generators also write a few tracked files (Contents.json, ic_launcher.xml,
# styles.xml...). They normally come out identical; if not, say so rather than
# leaving a surprise in git status.
tracked_after=$(git status --porcelain --untracked-files=no)
if [ "$tracked_after" != "$tracked_before" ]; then
  echo
  echo "warning: generating changed tracked files - review and commit them:" >&2
  echo "$tracked_after" >&2
fi

step "Building: ${BUILD[*]}"
"${BUILD[@]}"

if [ "$PLATFORM" = "ios" ]; then
  echo
  echo "Archive: build/ios/archive/Runner.xcarchive - open it in Xcode's Organizer to upload."
fi
