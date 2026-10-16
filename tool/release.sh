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
# The artwork itself lives in the points_verts_assets repo, which must be
# checked out next to this one. The script stops if that repo is behind its
# remote or its images no longer match the SVG master, then copies the artwork
# across with tool/sync_assets.sh instead of trusting what is on disk.

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

ASSETS_REPO="../points_verts_assets"

step "Checking $ASSETS_REPO is up to date"
if [ ! -d "$ASSETS_REPO/.git" ]; then
  echo "error: $ASSETS_REPO not found. Clone points_verts_assets next to this repo." >&2
  exit 1
fi
if git -C "$ASSETS_REPO" fetch -q 2>/dev/null; then
  behind=$(git -C "$ASSETS_REPO" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
  if [ "$behind" -gt 0 ]; then
    echo "error: $ASSETS_REPO is $behind commit(s) behind its remote. Pull it first." >&2
    exit 1
  fi
  echo "Up to date with its remote."
else
  echo "warning: couldn't reach $ASSETS_REPO's remote; using it as it is." >&2
fi

tracked_before=$(git status --porcelain --untracked-files=no | sort)

step "Fetching packages"
flutter pub get

step "Checking brand images against the SVG master"
dart run tool/build_brand_assets.dart --check --assets-repo "$ASSETS_REPO"

step "Syncing artwork from $ASSETS_REPO"
bash tool/sync_assets.sh "$ASSETS_REPO"

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
# leaving a surprise in git status. Only files this run changed are listed.
tracked_after=$(git status --porcelain --untracked-files=no | sort)
changed_by_run=$(comm -13 <(echo "$tracked_before") <(echo "$tracked_after"))
if [ -n "$changed_by_run" ]; then
  echo
  echo "warning: generating changed tracked files - review and commit them:" >&2
  echo "$changed_by_run" >&2
fi

step "Building: ${BUILD[*]}"
"${BUILD[@]}"

if [ "$PLATFORM" = "ios" ]; then
  echo
  echo "Archive: build/ios/archive/Runner.xcarchive - open it in Xcode's Organizer to upload."
fi
