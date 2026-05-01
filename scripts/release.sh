#!/bin/bash
# Release helper — builds the app, packages a zip, and (optionally) publishes
# a GitHub Release using `gh` CLI.
#
# Usage:
#   ./scripts/release.sh v1.0.0
#   ./scripts/release.sh v1.0.0 --no-publish    (faqat zip yaratadi)
set -euo pipefail

VERSION="${1:-}"
PUBLISH=true
[ "${2:-}" = "--no-publish" ] && PUBLISH=false

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>  (e.g. v1.0.0)  [--no-publish]" >&2
    exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Version semver formatida bo'lishi kerak: vMAJOR.MINOR.PATCH (masalan v1.0.0)" >&2
    exit 1
fi

APP_NAME="PrayerTimesBar"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${ROOT}/dist"
ZIP_NAME="${APP_NAME}-${VERSION}.zip"

GREEN='\033[0;32m'; NC='\033[0m'
info() { printf "${GREEN}==>${NC} %s\n" "$1"; }

cd "$ROOT"

info "Build (release)"
bash ./build.sh

info "Zip yaratilmoqda: ${DIST}/${ZIP_NAME}"
mkdir -p "$DIST"
rm -f "${DIST}/${ZIP_NAME}"
ditto -c -k --keepParent "${ROOT}/${APP_NAME}.app" "${DIST}/${ZIP_NAME}"

# Sha256 fingerprint
SHA256="$(shasum -a 256 "${DIST}/${ZIP_NAME}" | awk '{print $1}')"
info "SHA256: $SHA256"

if [ "$PUBLISH" = false ]; then
    info "Tayyor (publish o'tkazib yuborildi): ${DIST}/${ZIP_NAME}"
    exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI topilmadi. O'rnatish: brew install gh" >&2
    echo "Yoki --no-publish bilan ishlating va zip'ni qo'lda yuklang." >&2
    exit 1
fi

info "GitHub Release yaratilmoqda: $VERSION"
NOTES_FILE="$(mktemp)"
cat > "$NOTES_FILE" <<EOF
## ${APP_NAME} ${VERSION}

### O'rnatish (terminaldan)
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/main/install.sh | bash
\`\`\`

### Qo'lda
1. ${ZIP_NAME} ni yuklab oling
2. Ochib, ${APP_NAME}.app ni /Applications ga ko'chiring
3. Birinchi ochishda: right-click → Open

### SHA256
\`${SHA256}\`
EOF

gh release create "$VERSION" \
    "${DIST}/${ZIP_NAME}" \
    --title "$VERSION" \
    --notes-file "$NOTES_FILE"

rm -f "$NOTES_FILE"
info "Release yaratildi: $VERSION"
