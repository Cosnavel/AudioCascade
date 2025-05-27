import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showAccessibilityPermission = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with search
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "hifispeaker.2")
                        .font(.title2)
                        .foregroundColor(.accentColor)

                    Text("app_name".localized)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    // Settings button
                    Button(action: {
                        selectedTab = 2
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)

                // Manual Mode Banner
                if audioManager.isManualModeActive {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Text("manual_mode_active".localized)
                            .font(.caption)
                            .foregroundColor(.orange)

                        Spacer()

                        Button(action: {
                            audioManager.disableManualMode()
                        }) {
                            Text("manual_mode_disable".localized)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("search_placeholder".localized, text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }

            Divider()

            // Tab view
            TabView(selection: $selectedTab) {
                DeviceListView(
                    devices: filteredDevices(audioManager.inputDevices),
                    currentDevice: audioManager.currentInputDevice,
                    deviceType: .input
                )
                .tabItem {
                    Label("tab_input".localized, systemImage: "mic")
                }
                .tag(0)

                DeviceListView(
                    devices: filteredDevices(audioManager.outputDevices),
                    currentDevice: audioManager.currentOutputDevice,
                    deviceType: .output
                )
                .tabItem {
                    Label("tab_output".localized, systemImage: "hifispeaker")
                }
                .tag(1)

                SettingsView()
                    .tabItem {
                        Label("settings_title".localized, systemImage: "gearshape")
                    }
                    .tag(2)
            }
            .padding(.top, 8)
        }
        .frame(width: 400, height: 500)
        .onAppear {
            checkForAccessibilityPermission()
        }
        .sheet(isPresented: $showAccessibilityPermission) {
            AccessibilityPermissionView(isPresented: $showAccessibilityPermission)
        }
    }

    private func filteredDevices(_ devices: [AudioDevice]) -> [AudioDevice] {
        if searchText.isEmpty {
            return devices
        }
        return devices.filter { device in
            device.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func checkForAccessibilityPermission() {
        // Check if we need to show permission request
        if UserDefaults.standard.bool(forKey: "needsAccessibilityPermission") {
            // Check if permission is now granted
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

            if !accessEnabled && !UserDefaults.standard.bool(forKey: "accessibilityPermissionDismissed") {
                showAccessibilityPermission = true
            } else if accessEnabled {
                UserDefaults.standard.removeObject(forKey: "needsAccessibilityPermission")
            }
        }
    }
}
