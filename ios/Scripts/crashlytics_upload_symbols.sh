#!/bin/sh
#
# Uploads the build's dSYMs to Crashlytics, so crash reports are symbolicated.
# Wired in as the "[firebase_crashlytics] Crashlytics Upload Symbols" phase on
# the Runner target.
#
# `flutterfire configure` generated that phase as a one-liner calling
# $PODS_ROOT/FirebaseCrashlytics/upload-symbols. Since Flutter 3.47 the
# Firebase plugins come in through Swift Package Manager, and CocoaPods only
# installs the plugins that don't support it yet (google_maps_flutter_ios), so
# that file no longer exists and every iOS build failed. upload-symbols also
# ships in the firebase-ios-sdk package, which Xcode checks out under
# DerivedData; this looks in both places. If `flutterfire configure` is run
# again and rewrites the phase, point it back at this script.

set -eu

# Debug builds use DEBUG_INFORMATION_FORMAT = dwarf: there is no dSYM to upload,
# and they never reach users.
case "${CONFIGURATION:-Debug}" in
  Debug*)
    echo "Skipping Crashlytics symbol upload for a ${CONFIGURATION:-Debug} build."
    exit 0
    ;;
esac

# OBJROOT and BUILD_DIR both sit under DerivedData/<project>/Build/ unless a
# build overrides them (flutter sets its own BUILD_DIR), and Swift packages are
# checked out next to that Build folder.
spm_checkout() {
  echo "${1%%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
}

for candidate in \
  "${PODS_ROOT:-}/FirebaseCrashlytics/upload-symbols" \
  "$(spm_checkout "${OBJROOT:-}")" \
  "$(spm_checkout "${BUILD_DIR:-}")"; do
  if [ -x "$candidate" ]; then
    exec "$candidate" --flutter-project "$PROJECT_DIR/firebase_app_id_file.json"
  fi
done

echo "error: Crashlytics upload-symbols not found in Pods or in the Swift Package Manager checkouts. Crash reports from this build would not be symbolicated." >&2
exit 1
