import Foundation
import SwiftUI
import CoreLocation

@MainActor
final class PrayerTimesViewModel: ObservableObject {
    @Published var menuBarText: String = "..."
    @Published var prayers: [PrayerEntry] = []
    @Published var nextPrayerId: String?
    @Published var cityName: String = "Joylashuv kutilmoqda..."
    @Published var statusMessage: String = ""
    @Published var launchAtLoginEnabled: Bool = LaunchAtLogin.isEnabled
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")

    private let locationManager = LocationManager()
    private let prayerManager = PrayerTimesManager()

    private var tickTimer: Timer?
    private var locationRefreshTimer: Timer?

    init() {
        wireLocationCallbacks()
        locationManager.requestPermissionAndLocation()
        startTickTimer()
        startLocationRefreshTimer()
        applyAuthorization(locationManager.authorizationStatus)
    }

    deinit {
        tickTimer?.invalidate()
        locationRefreshTimer?.invalidate()
    }

    func refresh() {
        statusMessage = "Yangilanmoqda..."
        locationManager.requestPermissionAndLocation()
    }

    func toggleLaunchAtLogin() {
        let newValue = !launchAtLoginEnabled
        do {
            try LaunchAtLogin.setEnabled(newValue)
            launchAtLoginEnabled = LaunchAtLogin.isEnabled
        } catch {
            statusMessage = "Autostart xatosi: \(error.localizedDescription)"
        }
    }

    func toggleNotifications() {
        let newValue = !notificationsEnabled
        if newValue {
            Task { @MainActor in
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    notificationsEnabled = true
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                    NotificationManager.shared.reschedule(for: prayers)
                } else {
                    statusMessage = "Notifikatsiya ruxsati berilmadi"
                }
            }
        } else {
            notificationsEnabled = false
            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            NotificationManager.shared.clearAll()
        }
    }

    private func wireLocationCallbacks() {
        locationManager.onLocationUpdate = { [weak self] _ in
            Task { @MainActor in self?.recompute() }
        }
        locationManager.onCityResolved = { [weak self] city in
            Task { @MainActor in self?.cityName = city }
        }
        locationManager.onAuthorizationChange = { [weak self] status in
            Task { @MainActor in self?.applyAuthorization(status) }
        }
        locationManager.onError = { [weak self] error in
            Task { @MainActor in
                self?.statusMessage = "Xato: \(error.localizedDescription)"
            }
        }
    }

    private func applyAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            menuBarText = "📍 Ruxsat yo'q"
            statusMessage = "Sozlamalar > Maxfiylik > Joylashuv"
        case .notDetermined:
            menuBarText = "..."
            statusMessage = "Joylashuv ruxsati so'ralmoqda"
        default:
            statusMessage = ""
        }
    }

    private func startTickTimer() {
        let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.recompute() }
        }
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    private func startLocationRefreshTimer() {
        let timer = Timer(timeInterval: 1800, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.locationManager.refresh() }
        }
        RunLoop.main.add(timer, forMode: .common)
        locationRefreshTimer = timer
    }

    private func recompute() {
        guard let location = locationManager.location else { return }

        let now = Date()
        let newPrayers = prayerManager.entries(for: location, on: now)
        let prayersChanged = newPrayers != prayers
        prayers = newPrayers

        guard let next = prayerManager.nextPrayer(for: location, now: now) else {
            menuBarText = "?"
            return
        }
        nextPrayerId = next.id

        let interval = max(0, next.time.timeIntervalSince(now))
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        menuBarText = String(format: "%@ -%02d:%02d", next.nameUz, hours, minutes)
        statusMessage = ""

        if prayersChanged && notificationsEnabled {
            NotificationManager.shared.reschedule(for: prayers)
        }
    }
}
