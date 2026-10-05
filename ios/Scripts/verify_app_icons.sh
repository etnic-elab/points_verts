#!/bin/sh
#
# Fails the build when the generated app icons don't match what Contents.json
# says should be there.
#
# Version 1.7.1 shipped to the App Store with the old white, non-adapting icon.
# The launcher-icon config had been updated (brand-coloured corners, iOS dark
# and tinted variants) and Contents.json - which is committed - was updated to
# match, but the archive was cut on a machine where
# `dart run flutter_launcher_icons` had never run against the new config. The
# generated PNGs are gitignored, so that machine still had the previous icons:
# the light ones were stale and the Icon-App-Dark-* / Icon-App-Tinted-* files
# simply didn't exist. actool used what it found and the build succeeded.
#
# Nothing in git could catch that, which is why this check lives here. Wired in
# as the "Verify App Icons" run-script phase on the Runner target.

set -u

ICONSET="$SRCROOT/Runner/Assets.xcassets/AppIcon.appiconset"
CONTENTS="$ICONSET/Contents.json"
REGENERATE="Run 'dart run flutter_launcher_icons' from the project root, then build again."

# Stale icons only matter for something you can ship, and hard-failing every
# debug build would be miserable on a machine without the (gitignored) artwork.
case "${CONFIGURATION:-Debug}" in
  Debug*) SEVERITY="warning" ;;
  *) SEVERITY="error" ;;
esac

FAILED=0
report() {
  echo "$SEVERITY: $1" >&2
  FAILED=1
}

# Colour type from the PNG IHDR: byte 25 is 2 for RGB, 6 for RGBA.
png_color_type() {
  dd if="$1" bs=1 skip=25 count=1 2>/dev/null | od -An -tu1 | tr -d ' \n'
}

if [ ! -f "$CONTENTS" ]; then
  report "No AppIcon.appiconset/Contents.json. $REGENERATE"
else
  # Deliberately content-based rather than timestamp-based: a git checkout
  # restamps the config's mtime, so comparing modification times would fail on
  # a branch switch even when the icons are perfectly good.
  missing=""
  for name in $(grep -o '"filename"[^"]*"[^"]*"' "$CONTENTS" | sed 's/.*"\([^"]*\)"$/\1/'); do
    [ -f "$ICONSET/$name" ] || missing="$missing $name"
  done
  [ -z "$missing" ] || report "App icons referenced by Contents.json are missing:$missing. $REGENERATE"

  # The dark and tinted variants are what make the icon adapt on iOS 18+. If a
  # regenerate ever drops them the icon silently stops adapting, which is the
  # bug users reported, so treat their absence as a failure of its own.
  grep -q '"dark"' "$CONTENTS" || report "Contents.json declares no dark appearance. $REGENERATE"
  grep -q '"tinted"' "$CONTENTS" || report "Contents.json declares no tinted appearance. $REGENERATE"

  # iOS composites the dark and tinted icons over its own background, so those
  # two must keep their alpha channel while the light one must not have one.
  dark="$ICONSET/Icon-App-Dark-1024x1024@1x.png"
  light="$ICONSET/Icon-App-1024x1024@1x.png"
  if [ -f "$dark" ] && [ "$(png_color_type "$dark")" != "6" ]; then
    report "The dark app icon has no alpha channel, so it can't adapt. Check image_path_ios_dark_transparent. $REGENERATE"
  fi
  if [ -f "$light" ] && [ "$(png_color_type "$light")" = "6" ]; then
    report "The light app icon still has an alpha channel; the App Store rejects that. Check remove_alpha_ios. $REGENERATE"
  fi
fi

if [ "$FAILED" -eq 1 ] && [ "$SEVERITY" = "error" ]; then
  exit 1
fi
exit 0
