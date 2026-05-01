import SwiftUI

@main
struct PrayerTimesBarApp: App {
    @StateObject private var viewModel = PrayerTimesViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(viewModel: viewModel)
        } label: {
            Text(viewModel.menuBarText)
        }
        .menuBarExtraStyle(.window)
    }
}
