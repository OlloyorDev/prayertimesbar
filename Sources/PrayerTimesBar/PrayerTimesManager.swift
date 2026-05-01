import Foundation
import CoreLocation
import Adhan

struct PrayerEntry: Identifiable, Equatable {
    let id: String
    let nameUz: String
    let time: Date
    let isPrayer: Bool

    static func == (lhs: PrayerEntry, rhs: PrayerEntry) -> Bool {
        lhs.id == rhs.id && lhs.time == rhs.time
    }
}

struct PrayerTimesManager {
    func entries(for location: CLLocation, on date: Date = Date()) -> [PrayerEntry] {
        let coords = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        let cal = Calendar(identifier: .gregorian)
        let components = cal.dateComponents([.year, .month, .day], from: date)

        var params = CalculationMethod.northAmerica.params
        params.madhab = .hanafi
        params.adjustments.dhuhr = 4
        params.adjustments.maghrib = 2

        guard let times = PrayerTimes(
            coordinates: coords,
            date: components,
            calculationParameters: params
        ) else {
            return []
        }

        return [
            PrayerEntry(id: "fajr",    nameUz: "Bomdod",  time: times.fajr,    isPrayer: true),
            PrayerEntry(id: "sunrise", nameUz: "Quyosh",  time: times.sunrise, isPrayer: false),
            PrayerEntry(id: "dhuhr",   nameUz: "Peshin",  time: times.dhuhr,   isPrayer: true),
            PrayerEntry(id: "asr",     nameUz: "Asr",     time: times.asr,     isPrayer: true),
            PrayerEntry(id: "maghrib", nameUz: "Shom",    time: times.maghrib, isPrayer: true),
            PrayerEntry(id: "isha",    nameUz: "Xufton",  time: times.isha,    isPrayer: true)
        ]
    }

    func nextPrayer(for location: CLLocation, now: Date = Date()) -> PrayerEntry? {
        let today = entries(for: location, on: now).filter { $0.isPrayer }
        if let next = today.first(where: { $0.time > now }) {
            return next
        }
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        return entries(for: location, on: tomorrow).first { $0.id == "fajr" }
    }
}
