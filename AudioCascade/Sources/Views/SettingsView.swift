import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @AppStorage("startAtLogin") private var startAtLogin = false
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("checkInterval") private var checkInterval = 1.0
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("settings_title".localized)
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
                Section("settings_general".localized) {
                    Toggle("settings_start_login".localized, isOn: Binding(
                        get: { startAtLogin },
                        set: { newValue in
                            startAtLogin = newValue
                            if #available(macOS 13.0, *) {
                                if newValue {
                                    try? SMAppService.mainApp.register()
                                } else {
                                    try? SMAppService.mainApp.unregister()
                                }
                            } else {
                                // For macOS 12, we'll use the old SMLoginItemSetEnabled
                                // This requires a helper app, which we'll skip for now
                                print("Start at login not supported on macOS 12")
                            }
                        }
                    ))

                    Toggle("settings_show_dock".localized, isOn: Binding(
                        get: { showInDock },
                        set: { newValue in
                            showInDock = newValue
                            if let appDelegate = NSApp.delegate as? AppDelegate {
                                appDelegate.updateDockVisibility()
                            }
                        }
                    ))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("settings_check_interval".localized)
                        HStack {
                            Slider(value: $checkInterval, in: 0.5...5.0, step: 0.5)
                                .onChange(of: checkInterval) { newValue in
                                    audioManager.updateCheckInterval(newValue)
                                }
                            Text("settings_seconds".localized(with: checkInterval))
                                .frame(width: 80, alignment: .trailing)
                        }
                    }
                }

                Section("settings_device_management".localized) {
                    HStack {
                        Button("settings_reset_priorities".localized) {
                            audioManager.resetAllPriorities()
                            showResetConfirmation = true

                            // Hide confirmation after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showResetConfirmation = false
                            }
                        }

                        Spacer()

                        if showResetConfirmation {
                            Label("confirm_reset".localized, systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }

                    HStack {
                        Button("settings_clear_disconnected".localized) {
                            let count = audioManager.inputDevices.filter { !$0.isCurrentlyConnected }.count +
                                       audioManager.outputDevices.filter { !$0.isCurrentlyConnected }.count
                            audioManager.clearDisconnectedDevices()

                            if count > 0 {
                                showClearConfirmation = true

                                // Hide confirmation after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showClearConfirmation = false
                                }
                            }
                        }

                        Spacer()

                        if showClearConfirmation {
                            Label("confirm_cleared".localized(with: 0), systemImage: "trash.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                Section("settings_about".localized) {
                    HStack {
                        Text("settings_version".localized(with: "1.0.0"))
                        Spacer()
                        Text("© 2025")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("settings_developer".localized(with: "Niclas Kahlmeier"))
                        Spacer()
                        Link("GitHub", destination: URL(string: "https://github.com/Cosnavel/AudioCascade")!)
                    }
                }
            }

            // Quit Button
            Section {
                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    Label("settings_quit".localized, systemImage: "power")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 350, height: 400)
        .animation(.easeInOut(duration: 0.2), value: showResetConfirmation)
        .animation(.easeInOut(duration: 0.2), value: showClearConfirmation)
    }
}
