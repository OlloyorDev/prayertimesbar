#!/bin/bash
# PrayerTimesBar uninstaller
set -euo pipefail

APP_NAME="PrayerTimesBar"
APP_PATH="/Applications/${APP_NAME}.app"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
info() { printf "${GREEN}==>${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}!${NC}  %s\n" "$1"; }

if [ ! -d "$APP_PATH" ]; then
    warn "${APP_NAME} o'rnatilmagan"
    exit 0
fi

info "${APP_NAME} to'xtatilmoqda"
killall "$APP_NAME" 2>/dev/null || true

info "App o'chirilmoqda: $APP_PATH"
if [ -w "/Applications" ]; then
    rm -rf "$APP_PATH"
else
    sudo rm -rf "$APP_PATH"
fi

info "UserDefaults tozalanmoqda"
defaults delete com.onx.PrayerTimesBar 2>/dev/null || true

info "Tayyor. ${APP_NAME} to'liq o'chirildi."
warn "Eslatma: 'Login Items' va 'Notifications' sozlamalari System Settings'da qolishi mumkin."
