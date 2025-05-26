import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @AppStorage("autoStartAtLogin") private var autoStartAtLogin = false
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("checkInterval") private var checkInterval = 1.0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("Settings")
                    .font(.headline)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            // Settings Content
            Form {
                Section("General") {
                    Toggle("Start at Login", isOn: $autoStartAtLogin)
                        .onChange(of: autoStartAtLogin) { newValue in
                            // TODO: Implement login item
                        }

                    Toggle("Show in Dock", isOn: $showInDock)
                        .onChange(of: showInDock) { newValue in
                            NSApp.setActivationPolicy(newValue ? .regular : .accessory)
                        }
                }

                Section("Audio Management") {
                    HStack {
                        Text("Check Interval")
                        Slider(value: $checkInterval, in: 0.5...5.0, step: 0.5)
                        Text("\(checkInterval, specifier: "%.1f")s")
                            .monospacedDigit()
                            .frame(width: 40)
                    }

                    Button("Reset All Priorities") {
                        audioManager.resetAllPriorities()
                    }
                    .foregroundColor(.red)

                    Button("Clear Disconnected Devices") {
                        audioManager.clearDisconnectedDevices()
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link("GitHub Repository", destination: URL(string: "https://github.com/yourusername/AudioCascade")!)

                    Link("Report an Issue", destination: URL(string: "https://github.com/yourusername/AudioCascade/issues")!)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
