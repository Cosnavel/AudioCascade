import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @AppStorage("autoStartAtLogin") private var autoStartAtLogin = false
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
                    Toggle("settings_start_login".localized, isOn: $autoStartAtLogin)
                        .onChange(of: autoStartAtLogin) { newValue in
                            if newValue {
                                try? SMAppService.mainApp.register()
                            } else {
                                try? SMAppService.mainApp.unregister()
                            }
                        }

                    Toggle("settings_show_dock".localized, isOn: $showInDock)
                        .onChange(of: showInDock) { newValue in
                            NSApp.setActivationPolicy(newValue ? .regular : .accessory)
                        }
                }

                Section("settings_audio".localized) {
                    HStack {
                        Text("settings_check_interval".localized)
                        Slider(value: $checkInterval, in: 0.5...5.0, step: 0.5)
                            .onChange(of: checkInterval) { newValue in
                                audioManager.updateCheckInterval(newValue)
                            }
                        Text("\(checkInterval, specifier: "%.1f")s")
                            .monospacedDigit()
                            .frame(width: 40)
                    }

                    // Reset Priorities with inline confirmation
                    if showResetConfirmation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("alert_reset_message".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("alert_cancel".localized) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showResetConfirmation = false
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("alert_reset".localized) {
                                    audioManager.resetAllPriorities()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showResetConfirmation = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(.white)
                                .tint(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button("settings_reset_priorities".localized) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showResetConfirmation = true
                                showClearConfirmation = false
                            }
                        }
                        .foregroundColor(.red)
                    }

                    // Clear Disconnected with inline confirmation
                    if showClearConfirmation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("alert_clear_message".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("alert_cancel".localized) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showClearConfirmation = false
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("alert_clear".localized) {
                                    audioManager.clearDisconnectedDevices()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showClearConfirmation = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(.white)
                                .tint(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button("settings_clear_disconnected".localized) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showClearConfirmation = true
                                showResetConfirmation = false
                            }
                        }
                    }
                }

                Section("settings_about".localized) {
                    HStack {
                        Text("settings_version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link("settings_github".localized, destination: URL(string: "https://github.com/Cosnavel/AudioCascade")!)

                    Link("settings_report_issue".localized, destination: URL(string: "https://github.com/Cosnavel/AudioCascade/issues")!)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
