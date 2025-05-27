import SwiftUI

struct DeviceRowView: View {
    @ObservedObject var device: AudioDevice
    let isCurrentDevice: Bool
    let deviceType: AudioDeviceType
    let isDragging: Bool
    @EnvironmentObject var audioManager: AudioDeviceManager
    @State private var isHovering = false
    @State private var isEditingShortcut = false

    var body: some View {
        HStack(spacing: 12) {
            // Priority Badge
            Text("\(device.priority)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(priorityColor)
                .clipShape(Circle())

            // Device Icon
            Image(systemName: deviceIcon)
                .font(.title3)
                .foregroundColor(device.isEnabled ? .primary : .secondary)
                .frame(width: 24)

            // Device Info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(device.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(isCurrentDevice ? .semibold : .regular)
                        .foregroundColor(device.isEnabled ? .primary : .secondary)

                    if isCurrentDevice {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }

                    if !device.isCurrentlyConnected {
                        Image(systemName: "moon.zzz")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .help("status_disconnected".localized)
                    }
                }

                HStack(spacing: 8) {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let shortcut = device.keyboardShortcut {
                        Text(shortcut.displayString)
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            // Action Buttons
            HStack(spacing: 8) {
                // Shortcut Button
                Button(action: {
                    isEditingShortcut.toggle()
                }) {
                    Image(systemName: device.keyboardShortcut != nil ? "command.square.fill" : "command.square")
                        .font(.system(size: 14))
                        .foregroundColor(device.keyboardShortcut != nil ? .white : .secondary)
                        .frame(width: 20, height: 20)
                        .background(device.keyboardShortcut != nil ? Color.accentColor : Color.clear)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help(device.keyboardShortcut != nil ? "Shortcut: \(device.keyboardShortcut!.displayString)" : "shortcut_edit".localized)

                // Move Up/Down
                if audioManager.inputDevices.count > 1 || audioManager.outputDevices.count > 1 {
                    Button(action: { audioManager.moveDevice(device, direction: .up) }) {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canMoveUp)
                    .opacity(canMoveUp ? 1 : 0.3)

                    Button(action: { audioManager.moveDevice(device, direction: .down) }) {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canMoveDown)
                    .opacity(canMoveDown ? 1 : 0.3)
                }

                // Enable/Disable Toggle
                Toggle("", isOn: Binding(
                    get: { device.isEnabled },
                    set: { _ in audioManager.toggleDeviceEnabled(device) }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
            }
        }
        .padding(12)
        .background(backgroundStyle)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: isCurrentDevice ? 2 : 1)
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .opacity(isDragging ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("menu_set_default".localized) {
                audioManager.setDevice(device, for: deviceType, isManual: true)
            }
            .disabled(!device.isEnabled || !device.isCurrentlyConnected)

            Divider()

            Button("menu_edit_shortcut".localized) {
                isEditingShortcut = true
            }

            if device.keyboardShortcut != nil {
                Button("menu_clear_shortcut".localized) {
                    device.keyboardShortcut = nil
                    audioManager.saveDevices()
                }
            }

            Divider()

            Button(device.isEnabled ? "menu_disable".localized : "menu_enable".localized) {
                audioManager.toggleDeviceEnabled(device)
            }
        }
        .popover(isPresented: $isEditingShortcut) {
            VStack(spacing: 12) {
                Text("shortcut_title".localized)
                    .font(.headline)

                Text(device.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ShortcutRecorderView(shortcut: Binding(
                    get: { device.keyboardShortcut },
                    set: { newShortcut in
                        device.keyboardShortcut = newShortcut
                        audioManager.saveDevices()
                    }
                ))

                Text("shortcut_help".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("done".localized) {
                    isEditingShortcut = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding()
            .frame(width: 300)
        }
    }

    private var deviceIcon: String {
        switch device.name.lowercased() {
        case let name where name.contains("airpods"):
            return "airpodspro"
        case let name where name.contains("macbook"):
            return "laptopcomputer"
        case let name where name.contains("display") || name.contains("monitor"):
            return "display"
        case let name where name.contains("logitech"):
            return "camera"
        default:
            return deviceType == .input ? "mic" : "hifispeaker"
        }
    }

    private var priorityColor: Color {
        switch device.priority {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        default: return .gray
        }
    }

    private var statusText: String {
        if !device.isEnabled {
            return "status_disabled".localized
        } else if !device.isCurrentlyConnected {
            return "status_not_connected".localized(with: formattedDate)
        } else if isCurrentDevice {
            return "status_active".localized
        } else {
            return "status_ready".localized
        }
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: device.lastSeen, relativeTo: Date())
    }

    private var backgroundStyle: some ShapeStyle {
        if isCurrentDevice {
            return Color.accentColor.opacity(0.1)
        } else if !device.isEnabled {
            return Color.gray.opacity(0.05)
        } else {
            return Color(NSColor.controlBackgroundColor)
        }
    }

    private var borderColor: Color {
        if isCurrentDevice {
            return .accentColor
        } else if !device.isEnabled {
            return .gray.opacity(0.3)
        } else {
            return .gray.opacity(0.2)
        }
    }

    private var canMoveUp: Bool {
        let devices = deviceType == .input ? audioManager.inputDevices : audioManager.outputDevices
        guard let index = devices.firstIndex(where: { $0.uid == device.uid }) else { return false }
        return index > 0
    }

    private var canMoveDown: Bool {
        let devices = deviceType == .input ? audioManager.inputDevices : audioManager.outputDevices
        guard let index = devices.firstIndex(where: { $0.uid == device.uid }) else { return false }
        return index < devices.count - 1
    }
}
