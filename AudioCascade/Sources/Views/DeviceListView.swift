import SwiftUI
import UniformTypeIdentifiers

struct DeviceListView: View {
    let devices: [AudioDevice]
    let currentDevice: AudioDevice?
    let deviceType: AudioDeviceType
    @EnvironmentObject var audioManager: AudioDeviceManager
    @State private var draggedDevice: AudioDevice?

    var body: some View {
        VStack(spacing: 12) {
            if devices.isEmpty {
                EmptyStateView(deviceType: deviceType)
            } else {
                ForEach(devices, id: \.id) { device in
                    DeviceRowView(
                        device: device,
                        isCurrentDevice: currentDevice?.uid == device.uid,
                        deviceType: deviceType,
                        isDragging: draggedDevice?.uid == device.uid
                    )
                    .id(device.id)
                    .onDrag {
                        self.draggedDevice = device
                        return NSItemProvider(object: device.uid as NSString)
                    } preview: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.3))
                            .frame(width: 300, height: 60)
                            .overlay(
                                HStack {
                                    Image(systemName: deviceType == .input ? "mic" : "hifispeaker")
                                        .font(.title3)
                                    Text(device.name)
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                            )
                    }
                    .onDrop(of: [UTType.text], delegate: DeviceDropDelegate(
                        device: device,
                        devices: devices,
                        draggedDevice: $draggedDevice,
                        deviceType: deviceType,
                        audioManager: audioManager
                    ))
                }
            }
        }
        .onChange(of: draggedDevice) { _ in
            if draggedDevice == nil {
                // Reset when drag ends
            }
        }
    }
}

struct DeviceDropDelegate: DropDelegate {
    let device: AudioDevice
    let devices: [AudioDevice]
    @Binding var draggedDevice: AudioDevice?
    let deviceType: AudioDeviceType
    let audioManager: AudioDeviceManager

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedDevice = draggedDevice else { return false }
        guard draggedDevice.uid != device.uid else { return false }

        // Find indices
        guard let fromIndex = devices.firstIndex(where: { $0.uid == draggedDevice.uid }),
              let toIndex = devices.firstIndex(where: { $0.uid == device.uid }) else {
            return false
        }

        // Reorder devices
        withAnimation(.easeInOut(duration: 0.3)) {
            if deviceType == .input {
                audioManager.reorderInputDevice(from: fromIndex, to: toIndex)
            } else {
                audioManager.reorderOutputDevice(from: fromIndex, to: toIndex)
            }
        }

        self.draggedDevice = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        // Optional: Add visual feedback when hovering
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {
        // Clean up when exiting drop zone
    }
}

struct EmptyStateView: View {
    let deviceType: AudioDeviceType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: deviceType == .input ? "mic.slash" : "speaker.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(deviceType == .input ? "empty_input_title".localized : "empty_output_title".localized)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("empty_subtitle".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}
