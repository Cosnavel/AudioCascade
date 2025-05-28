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

            Divider()

            // Settings Content
            ScrollView {
                VStack(spacing: 20) {
                    // General Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings_general".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(spacing: 8) {
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
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }

                    // Audio Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings_audio".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("settings_check_interval".localized)
                                HStack {
                                    Slider(value: $checkInterval, in: 0.5...5.0, step: 0.5)
                                        .onChange(of: checkInterval) { newValue in
                                            audioManager.updateCheckInterval(newValue)
                                        }
                                    Text("\(checkInterval, specifier: "%.1f")s")
                                        .frame(width: 40, alignment: .trailing)
                                        .monospacedDigit()
                                }
                            }

                            Button(action: {
                                audioManager.resetAllPriorities()
                                showResetConfirmation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showResetConfirmation = false
                                }
                            }) {
                                Label("settings_reset_priorities".localized, systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)
                            .buttonStyle(.bordered)

                            Button(action: {
                                audioManager.clearDisconnectedDevices()
                                showClearConfirmation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showClearConfirmation = false
                                }
                            }) {
                                Label("settings_clear_disconnected".localized, systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }

                    // About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings_about".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("settings_version".localized)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            Link(destination: URL(string: "https://github.com/Cosnavel/AudioCascade")!) {
                                HStack {
                                    Label("settings_github".localized, systemImage: "chevron.left.forwardslash.chevron.right")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.secondary)
                                }
                            }

                            Link(destination: URL(string: "https://github.com/Cosnavel/AudioCascade/issues")!) {
                                HStack {
                                    Label("settings_report_issue".localized, systemImage: "exclamationmark.bubble")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(alignment: .bottom) {
            // Confirmation messages
            if showResetConfirmation || showClearConfirmation {
                HStack {
                    Image(systemName: showResetConfirmation ? "checkmark.circle.fill" : "trash.circle.fill")
                        .foregroundColor(showResetConfirmation ? .green : .orange)
                    Text(showResetConfirmation ? "confirm_reset".localized : "confirm_cleared".localized(with: 0))
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showResetConfirmation)
        .animation(.easeInOut(duration: 0.2), value: showClearConfirmation)
    }
}
