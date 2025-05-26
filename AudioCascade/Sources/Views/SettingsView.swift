import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @AppStorage("autoStartAtLogin") private var autoStartAtLogin = false
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("checkInterval") private var checkInterval = 1.0
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    @State private var showClearAlert = false

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
                            if newValue {
                                try? SMAppService.mainApp.register()
                            } else {
                                try? SMAppService.mainApp.unregister()
                            }
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
                            .onChange(of: checkInterval) { newValue in
                                audioManager.updateCheckInterval(newValue)
                            }
                        Text("\(checkInterval, specifier: "%.1f")s")
                            .monospacedDigit()
                            .frame(width: 40)
                    }

                    Button("Reset All Priorities") {
                        showResetAlert = true
                    }
                    .foregroundColor(.red)
                    .alert("Reset Priorities?", isPresented: $showResetAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            audioManager.resetAllPriorities()
                        }
                    } message: {
                        Text("This will reset all device priorities to their default order.")
                    }

                    Button("Clear Disconnected Devices") {
                        showClearAlert = true
                    }
                    .alert("Clear Disconnected Devices?", isPresented: $showClearAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Clear", role: .destructive) {
                            audioManager.clearDisconnectedDevices()
                        }
                    } message: {
                        Text("This will remove all disconnected devices from your saved list.")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link("GitHub Repository", destination: URL(string: "https://github.com/Cosnavel/AudioCascade")!)

                    Link("Report an Issue", destination: URL(string: "https://github.com/Cosnavel/AudioCascade/issues")!)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
