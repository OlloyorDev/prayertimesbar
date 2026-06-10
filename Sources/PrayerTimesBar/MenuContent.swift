import SwiftUI

struct MenuContent: View {
    @ObservedObject var viewModel: PrayerTimesViewModel
    @State private var tasbehExpanded = false

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

            tasbehSection

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
    private var tasbehSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    tasbehExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .foregroundStyle(.secondary)
                    Text("Tasbeh")
                        .font(.callout)
                    Spacer()
                    Image(systemName: tasbehExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if tasbehExpanded {
                HStack(spacing: 8) {
                    Text("\(viewModel.tasbehCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(minWidth: 56, alignment: .leading)

                    Spacer()

                    Button {
                        viewModel.resetTasbeh()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.tasbehCount == 0)
                    .help("Nolga qaytarish")

                    Button {
                        viewModel.incrementTasbeh()
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .help("Sanash")
                }
            }
        }
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
