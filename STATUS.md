# PrayerTimesBar — Loyiha statusi

> Oxirgi yangilanish: 2026-05-01

## Loyiha haqida

macOS uchun menubar namoz vaqtlari ilovasi.
- **Stack:** Swift 5.9, SwiftUI, Swift Package Manager
- **Asosiy kutubxona:** [adhan-swift](https://github.com/batoulapps/adhan-swift) v1.4.0+
- **Bundle ID:** `com.onx.PrayerTimesBar`
- **Min macOS:** 13.0 (Ventura)
- **UI tili:** O'zbekcha (Bomdod, Quyosh, Peshin, Asr, Shom, Xufton)
- **Hisoblash:** northAmerica method + hanafi mazhab, peshin +4 daq, shom +2 daq tuzatish

## Hozirgi status: ✅ v1.0.0 RELEASED

- **Repo:** https://github.com/OlloyorDev/prayertimesbar (publik)
- **Release:** https://github.com/OlloyorDev/prayertimesbar/releases/tag/v1.0.0
- **Zip SHA256:** `3a997d4a0c62774c82fb98ea7d6993bc033877b814b19c4656f62bf960e30090`
- **Imzo:** Ad-hoc (`codesign --sign -`) — Apple Dev account yo'q

## Fayl tuzilishi

```
prayertimesbar/
├── Package.swift              # SPM manifest
├── Info.plist                 # Bundle metadata, LSUIElement=true (Dock'da yo'q)
├── AppIcon.icns
├── build.sh                   # .app bundle yasaydi + ad-hoc imzo
├── install.sh                 # foydalanuvchi installer (lokal/masofaviy auto-detect)
├── uninstall.sh               # to'liq o'chirish + UserDefaults tozalash
├── scripts/release.sh         # gh CLI orqali release publish
├── generate_icon.swift        # icon yaratish utility
└── Sources/PrayerTimesBar/
    ├── PrayerTimesBarApp.swift      # @main, MenuBarExtra
    ├── PrayerTimesViewModel.swift   # state, timers (30s tick, 30min location refresh)
    ├── PrayerTimesManager.swift     # Adhan integration
    ├── LocationManager.swift        # CoreLocation + reverse geocoding
    ├── NotificationManager.swift    # 5 daq oldin eslatma
    ├── LaunchAtLogin.swift          # SMAppService
    └── MenuContent.swift            # SwiftUI menyu UI
```

## Foydalanuvchi komandalari

**O'rnatish:**
```bash
curl -fsSL https://raw.githubusercontent.com/OlloyorDev/prayertimesbar/main/install.sh | bash
```

**O'chirish:**
```bash
curl -fsSL https://raw.githubusercontent.com/OlloyorDev/prayertimesbar/main/uninstall.sh | bash
```

`install.sh` aqlli — `Package.swift` topsa lokal build qiladi, topmasa GitHub release'dan zip oladi.

## Yangi release qilish (developer)

```bash
cd /Users/onx/learn/prayertimesbar
./scripts/release.sh v1.0.1     # build → zip → publish
./scripts/release.sh v1.0.1 --no-publish   # faqat dist/ ga zip
```

Talab: `gh` CLI o'rnatilgan va auth bo'lgan (hozir OlloyorDev sifatida login).

## Strategik qarorlar (nega shunday)

| Qaror | Sabab |
|---|---|
| App Store **yo'q** | $99/yil to'lash xohlanmagan |
| Notarization **yo'q** | Apple Dev account talab qiladi |
| Ad-hoc imzo + `curl \| bash` | Bepul, ishlaydi, niche audience uchun yetarli |
| Opensource | Trust + community kontributsiya |
| Niche: O'zbek + muslim mac userlar | "Ko'p applar bor" — lekin o'zbekcha + opensource yo'q |

## Keyingi qadamlar (TODO)

### Tezda
- [ ] **README.md** — repo "yuzi" (hozir bo'sh ko'rinadi)
- [ ] **LICENSE** — MIT tavsiya qilinadi
- [ ] **Screenshot/GIF** — README va release uchun

### O'rta muddat
- [ ] **Homebrew custom tap** (UX yaxshilash)
  - Yangi repo: `github.com/OlloyorDev/homebrew-tap`
  - `Casks/prayertimesbar.rb` formula
  - Foydalanuvchi: `brew install --cask olloyordev/tap/prayertimesbar`
  - Cask shabloni allaqachon muhokama qilingan

### Uzoq muddat (xohlasa)
- [ ] Auto-update mexanizmi (Sparkle framework)
- [ ] Promotion: r/macapps, Show HN, Telegram (uzbek/muslim guruhlar)
- [ ] Notarization (agar Dev account olinsa)

## Ma'lum cheklovlar / muammolar

- **Gatekeeper warning:** Ad-hoc imzo bo'lgani uchun foydalanuvchi birinchi ochishda warning ko'rishi mumkin. Yechim: System Settings → Privacy & Security → "Open Anyway". `install.sh` `xattr -dr com.apple.quarantine` qiladi, lekin yangi macOS 15+ da har doim ham yetmaydi.
- **README yo'q:** GitHub sahifasi hozircha bo'sh ko'rinadi.
- **Faqat macOS:** Linux/Windows yo'q (planda ham yo'q).

## Texnik muhit (lokal)

- **Working dir:** `/Users/onx/learn/prayertimesbar`
- **Git remote:** `https://github.com/OlloyorDev/prayertimesbar.git` (HTTPS)
- **gh CLI:** o'rnatilgan, login: OlloyorDev
- **Swift:** tizimda mavjud (build muvaffaqiyatli)
