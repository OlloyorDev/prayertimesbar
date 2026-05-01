import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let minutesBefore: Int = 5

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { cont in
            center.getNotificationSettings { settings in
                cont.resume(returning: settings.authorizationStatus)
            }
        }
    }

    func reschedule(for prayers: [PrayerEntry]) {
        center.removeAllPendingNotificationRequests()

        let now = Date()
        let calendar = Calendar.current

        for prayer in prayers where prayer.isPrayer {
            guard let fireDate = calendar.date(byAdding: .minute, value: -minutesBefore, to: prayer.time),
                  fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(prayer.nameUz) namozi yaqinlashdi"
            content.body = "\(minutesBefore) daqiqadan so'ng — \(formatTime(prayer.time))"
            content.sound = .default

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "prayer.\(prayer.id).\(comps.day ?? 0)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func clearAll() {
        center.removeAllPendingNotificationRequests()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
