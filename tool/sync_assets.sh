#!/usr/bin/env bash
#
# Copies the artwork this repo can't hold (copyright - see "Missing Assets" in
# README.md) from the points_verts_assets repo checked out next to it.
#
#     tool/sync_assets.sh [path/to/points_verts_assets]
#
# Only artwork is synced; secrets (.env, google-services.json, ...) are set up
# by hand. The launcher-icon and splash folders are mirrored, so a file removed
# from points_verts_assets disappears here too instead of lingering on disk -
# leftover files are how stale icons shipped before.

set -euo pipefail

cd "$(dirname "$0")/.."
SRC="${1:-../points_verts_assets}"

if [ ! -d "$SRC/assets" ]; then
  echo "error: $SRC/assets not found. Clone points_verts_assets next to this repo." >&2
  exit 1
fi

changed=0
copy() {
  local from="$SRC/$1" to="$1"
  if [ ! -f "$from" ]; then
    echo "error: $from is missing." >&2
    exit 1
  fi
  if ! cmp -s "$from" "$to" 2>/dev/null; then
    mkdir -p "$(dirname "$to")"
    cp "$from" "$to"
    echo "updated $to"
    changed=1
  fi
}

# Mirrors one folder's PNGs: copies every source file, removes the rest.
mirror() {
  local dir="$1" f
  for f in "$SRC/$dir"/*.png; do
    copy "$dir/$(basename "$f")"
  done
  for f in "$dir"/*.png; do
    [ -e "$f" ] || continue
    if [ ! -f "$SRC/$f" ]; then
      rm "$f"
      echo "removed $f"
      changed=1
    fi
  done
}

# Rendered from assets/brand/app_icon.svg by tool/build_brand_assets.dart.
mirror assets/launcher_icons
mirror assets/splash
for theme in light dark; do
  copy "assets/$theme/app_logo.png"
  # The green disc: the Points Verts walk symbol (walk icons, map markers).
  copy "assets/$theme/logo.png"
  copy "assets/$theme/logo-annule.png"
done

# Hand-made Android notification icon.
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  copy "android/app/src/main/res/drawable-$density/ic_notification.png"
done

[ "$changed" -eq 1 ] || echo "Assets already in sync with $SRC."
