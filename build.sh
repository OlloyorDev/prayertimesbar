#!/bin/bash
set -euo pipefail

APP_NAME="PrayerTimesBar"
BUNDLE="${APP_NAME}.app"
ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${ROOT}/.build/release"
APP_DIR="${ROOT}/${BUNDLE}"

echo "==> Building ${APP_NAME} (release)"
cd "${ROOT}"
swift build -c release

echo "==> Creating ${BUNDLE} bundle"
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
cp "${ROOT}/Info.plist" "${APP_DIR}/Contents/Info.plist"

if [ -f "${ROOT}/AppIcon.icns" ]; then
    cp "${ROOT}/AppIcon.icns" "${APP_DIR}/Contents/Resources/AppIcon.icns"
fi

echo "==> Ad-hoc code signing"
codesign --force --deep --sign - "${APP_DIR}"

echo ""
echo "Done: ${APP_DIR}"
echo ""
echo "Run:    open '${APP_DIR}'"
echo "Stop:   killall ${APP_NAME}"
