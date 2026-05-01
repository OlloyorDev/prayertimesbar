import SwiftUI

struct MenuContent: View {
    @ObservedObject var viewModel: PrayerTimesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .foregroundStyle(.secondary)
                Text(viewModel.cityName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
            }

            Divider()

            VStack(spacing: 6) {
                ForEach(viewModel.prayers) { prayer in
                    row(for: prayer)
                }
            }

            if !viewModel.statusMessage.isEmpty {
                Divider()
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            Toggle(isOn: Binding(
                get: { viewModel.launchAtLoginEnabled },
                set: { _ in viewModel.toggleLaunchAtLogin() }
            )) {
                Text("Tizim ishga tushganda")
                    .font(.callout)
            }
            .toggleStyle(.switch)
            .controlSize(.small)

            Toggle(isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { _ in viewModel.toggleNotifications() }
            )) {
                Text("Eslatma (5 daq oldin)")
                    .font(.callout)
            }
            .toggleStyle(.switch)
            .controlSize(.small)

            Divider()

            HStack {
                Button {
                    viewModel.refresh()
                } label: {
                    Label("Yangilash", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Chiqish") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.red)
            }
        }
        .padding(14)
        .frame(width: 260)
    }

    @ViewBuilder
    private func row(for prayer: PrayerEntry) -> some View {
        let isNext = viewModel.nextPrayerId == prayer.id
        HStack {
            Text(prayer.nameUz)
                .foregroundStyle(prayer.isPrayer ? .primary : .secondary)
            Spacer()
            Text(prayer.time, style: .time)
                .monospacedDigit()
        }
        .fontWeight(isNext ? .bold : .regular)
        .foregroundStyle(isNext ? Color.accentColor : (prayer.isPrayer ? Color.primary : Color.secondary))
    }
}
