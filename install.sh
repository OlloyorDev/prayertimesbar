#!/bin/bash
# PrayerTimesBar installer — local build OR remote download
# Usage:
#   Local:  ./install.sh                        (clone qilingan repo ichidan)
#   Remote: curl -fsSL <url>/install.sh | bash  (faqat tayyor app yuklab oladi)
set -euo pipefail

APP_NAME="PrayerTimesBar"
INSTALL_DIR="/Applications"
GITHUB_REPO="${GITHUB_REPO:-YOUR_USERNAME/prayertimesbar}"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { printf "${GREEN}==>${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}!${NC}  %s\n" "$1"; }
err()  { printf "${RED}✗${NC}  %s\n" "$1" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || err "Faqat macOS uchun"

SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

APP_PATH=""

if [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/Package.swift" ]; then
    info "Manbadan build qilinmoqda (lokal rejim)"
    command -v swift >/dev/null 2>&1 || err "Swift topilmadi. Avval: xcode-select --install"
    cd "$SCRIPT_DIR"
    bash ./build.sh
    APP_PATH="${SCRIPT_DIR}/${APP_NAME}.app"
else
    info "GitHub release'dan yuklab olinmoqda (masofaviy rejim)"
    [ "$GITHUB_REPO" != "YOUR_USERNAME/prayertimesbar" ] || \
        err "GITHUB_REPO sozlanmagan. install.sh ichida YOUR_USERNAME ni o'zgartiring."

    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    API="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
    URL="$(curl -fsSL "$API" | grep -o 'https://[^"]*\.zip' | head -1)" || \
        err "Release ma'lumotini olib bo'lmadi: $API"
    [ -n "$URL" ] || err "Hech qanday .zip release topilmadi"

    info "Yuklanmoqda: $URL"
    curl -fL# "$URL" -o "$TMP/app.zip"

    info "Arxiv ochilmoqda"
    ditto -x -k "$TMP/app.zip" "$TMP/extracted"
    APP_PATH="$(find "$TMP/extracted" -maxdepth 3 -name "${APP_NAME}.app" -type d | head -1)"
    [ -n "$APP_PATH" ] || err "${APP_NAME}.app arxivda topilmadi"
fi

info "${INSTALL_DIR} ga o'rnatilmoqda"

if [ -d "${INSTALL_DIR}/${APP_NAME}.app" ]; then
    warn "Eski versiya topildi — almashtirilmoqda"
    killall "${APP_NAME}" 2>/dev/null || true
    sleep 1
    if [ -w "${INSTALL_DIR}" ]; then
        rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
    else
        sudo rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
    fi
fi

if [ -w "${INSTALL_DIR}" ]; then
    cp -R "$APP_PATH" "${INSTALL_DIR}/"
else
    info "Administrator paroli kerak (/Applications uchun)"
    sudo cp -R "$APP_PATH" "${INSTALL_DIR}/"
fi

xattr -dr com.apple.quarantine "${INSTALL_DIR}/${APP_NAME}.app" 2>/dev/null || true

info "O'rnatildi: ${INSTALL_DIR}/${APP_NAME}.app"
open "${INSTALL_DIR}/${APP_NAME}.app"
info "Ishga tushirildi. Menubar'da vaqt ko'rinishi kerak."
