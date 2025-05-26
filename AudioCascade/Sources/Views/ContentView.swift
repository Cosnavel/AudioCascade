import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @State private var selectedTab: AudioDeviceType = .output
    @State private var searchText = ""
    @State private var updateTrigger = UUID()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()

            // Tab Selection
            Picker("Device Type", selection: $selectedTab) {
                ForEach(AudioDeviceType.allCases, id: \.self) { type in
                    Label(type == .input ? "tab_input".localized : "tab_output".localized, systemImage: type.systemSymbol)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("search_placeholder".localized, text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 8)

            // Device List
            ScrollView {
                VStack(spacing: 12) {
                    if selectedTab == .output {
                        DeviceListView(
                            devices: filteredDevices(audioManager.outputDevices),
                            currentDevice: audioManager.currentOutputDevice,
                            deviceType: .output
                        )
                        .id(updateTrigger)
                    } else {
                        DeviceListView(
                            devices: filteredDevices(audioManager.inputDevices),
                            currentDevice: audioManager.currentInputDevice,
                            deviceType: .input
                        )
                        .id(updateTrigger)
                    }
                }
                .padding()
            }
            .onReceive(audioManager.objectWillChange) { _ in
                updateTrigger = UUID()
            }

            Divider()

            // Footer
            FooterView()
        }
        .frame(width: 400, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func filteredDevices(_ devices: [AudioDevice]) -> [AudioDevice] {
        if searchText.isEmpty {
            return devices
        }
        return devices.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "hifispeaker.2.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("app_name".localized)
                    .font(.headline)
                Text("app_tagline".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                NSApp.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FooterView: View {
    @EnvironmentObject var audioManager: AudioDeviceManager
    @State private var showingSettings = false

    var body: some View {
        HStack {
            // Current Status
            VStack(alignment: .leading, spacing: 4) {
                if let outputDevice = audioManager.currentOutputDevice {
                    Label(outputDevice.name, systemImage: "speaker.wave.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let inputDevice = audioManager.currentInputDevice {
                    Label(inputDevice.name, systemImage: "mic")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Settings Button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(audioManager)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}
