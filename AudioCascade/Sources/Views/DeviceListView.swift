import SwiftUI

struct DeviceListView: View {
    let devices: [AudioDevice]
    let currentDevice: AudioDevice?
    let deviceType: AudioDeviceType
    @EnvironmentObject var audioManager: AudioDeviceManager

    var body: some View {
        VStack(spacing: 12) {
            if devices.isEmpty {
                EmptyStateView(deviceType: deviceType)
            } else {
                ForEach(devices, id: \.id) { device in
                    DeviceRowView(
                        device: device,
                        isCurrentDevice: currentDevice?.uid == device.uid,
                        deviceType: deviceType
                    )
                    .id(device.id)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    let deviceType: AudioDeviceType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: deviceType == .input ? "mic.slash" : "speaker.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No \(deviceType.rawValue) Devices")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Connect an audio device to see it here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}
