#!/bin/sh

set -eu

PROJECT_ROOT="${PROJECT_DIR}/.."
IOS_PLIST="${PROJECT_DIR}/Runner/GoogleService-Info.plist"
BUNDLE_ID="${PRODUCT_BUNDLE_IDENTIFIER:-${APP_BUNDLE_ID:-}}"
CONFIG_NAME="${CONFIGURATION:-unknown}"

fail() {
  echo "error: $1"
  exit 1
}

if [ "$CONFIG_NAME" != "Release" ] && [ "$CONFIG_NAME" != "Profile" ]; then
  exit 0
fi

if [ -z "$BUNDLE_ID" ]; then
  fail "Release builds require PRODUCT_BUNDLE_IDENTIFIER / APP_BUNDLE_ID."
fi

case "$BUNDLE_ID" in
  com.example*)
    fail "Release builds require a final Apple bundle ID. Current value: $BUNDLE_ID"
    ;;
esac

if [ ! -f "$IOS_PLIST" ]; then
  fail "Missing ios/Runner/GoogleService-Info.plist for $CONFIG_NAME build."
fi

if [ -x /usr/libexec/PlistBuddy ]; then
  PLIST_BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :BUNDLE_ID" "$IOS_PLIST" 2>/dev/null || true)
  if [ -n "$PLIST_BUNDLE_ID" ] && [ "$PLIST_BUNDLE_ID" != "$BUNDLE_ID" ]; then
    fail "GoogleService-Info.plist BUNDLE_ID ($PLIST_BUNDLE_ID) does not match PRODUCT_BUNDLE_IDENTIFIER ($BUNDLE_ID)."
  fi
fi

FIREBASE_OPTIONS_FILE="${PROJECT_ROOT}/lib/firebase_options.dart"
if [ -f "$FIREBASE_OPTIONS_FILE" ] && grep -q "iosBundleId: 'com.example" "$FIREBASE_OPTIONS_FILE"; then
  fail "lib/firebase_options.dart still contains example Apple bundle IDs. Regenerate FlutterFire config for the final app."
fi
