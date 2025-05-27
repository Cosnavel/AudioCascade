import Foundation
import CoreAudio
import AVFoundation
import Combine
import Carbon
import AppKit

class AudioDeviceManager: ObservableObject {
    @Published var inputDevices: [AudioDevice] = []
    @Published var outputDevices: [AudioDevice] = []
    @Published var currentInputDevice: AudioDevice?
    @Published var currentOutputDevice: AudioDevice?

    private var audioDeviceListener: AudioDeviceListener?
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    private var eventMonitor: Any?
    private var lastManualSwitchTime: Date?
    private let manualSwitchDelay: TimeInterval = 3.0 // Don't auto-switch for 3 seconds after manual switch
    private var notificationsEnabled = false

    init() {
        loadSavedDevices()
        setupAudioDeviceListener()
        refreshDevices()
        startMonitoring()
        setupGlobalHotkeys()
        // Don't request notifications in debug builds
        #if !DEBUG
        requestNotificationPermission()
        #endif
    }

    deinit {
        timer?.invalidate()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func requestNotificationPermission() {
        // Only try to use notifications if we have a proper bundle
        guard Bundle.main.bundleIdentifier != nil else {
            print("Running from command line, notifications disabled")
            return
        }

        do {
            // Dynamic import to avoid crash
            if let notificationCenter = NSClassFromString("UNUserNotificationCenter") as? NSObject.Type {
                notificationsEnabled = true
                // We'll handle notifications differently
            }
        }
    }

    private func setupAudioDeviceListener() {
        audioDeviceListener = AudioDeviceListener { [weak self] in
            DispatchQueue.main.async {
                self?.refreshDevices()
            }
        }
    }

    private func startMonitoring() {
        DispatchQueue.main.async { [weak self] in
            let interval = UserDefaults.standard.double(forKey: "checkInterval")
            let actualInterval = interval > 0 ? interval : 1.0
            self?.timer = Timer.scheduledTimer(withTimeInterval: actualInterval, repeats: true) { [weak self] _ in
                self?.checkAndApplyPriorities()
            }
        }
    }

    func refreshDevices() {
        let systemDevices = getSystemAudioDevices()

        // Track if any device connection status changed
        var connectionChanged = false

        // Separate input and output processing
        var newInputs: [AudioDevice] = []
        var newOutputs: [AudioDevice] = []

        // Process existing saved devices first
        for savedDevice in inputDevices {
            let wasConnected = savedDevice.isCurrentlyConnected
            savedDevice.isCurrentlyConnected = false
            // Check if this device is still connected
            if systemDevices.contains(where: { $0.uid == savedDevice.uid && $0.isInput }) {
                savedDevice.isCurrentlyConnected = true
                savedDevice.lastSeen = Date()
                // Check if device just reconnected
                if !wasConnected {
                    connectionChanged = true
                    print("Device reconnected: \(savedDevice.name)")
                }
            }
            newInputs.append(savedDevice)
        }

        for savedDevice in outputDevices {
            let wasConnected = savedDevice.isCurrentlyConnected
            savedDevice.isCurrentlyConnected = false
            // Check if this device is still connected
            if systemDevices.contains(where: { $0.uid == savedDevice.uid && $0.isOutput }) {
                savedDevice.isCurrentlyConnected = true
                savedDevice.lastSeen = Date()
                // Check if device just reconnected
                if !wasConnected {
                    connectionChanged = true
                    print("Device reconnected: \(savedDevice.name)")
                }
            }
            newOutputs.append(savedDevice)
        }

        // Add new devices that aren't in our saved list
        var newlyConnectedDevices: [AudioDevice] = []

        for systemDevice in systemDevices {
            if systemDevice.isInput && !newInputs.contains(where: { $0.uid == systemDevice.uid }) {
                let newDevice = systemDevice
                // New devices get priority 1
                newDevice.priority = 1

                // Shift all existing priorities down
                for existingDevice in newInputs {
                    existingDevice.priority += 1
                }

                newInputs.append(newDevice)
                newlyConnectedDevices.append(newDevice)
                connectionChanged = true
                print("New input device detected: \(newDevice.name) - Setting as priority 1")
            }

            if systemDevice.isOutput && !newOutputs.contains(where: { $0.uid == systemDevice.uid }) {
                let newDevice = systemDevice
                // New devices get priority 1
                newDevice.priority = 1

                // Shift all existing priorities down
                for existingDevice in newOutputs {
                    existingDevice.priority += 1
                }

                newOutputs.append(newDevice)
                newlyConnectedDevices.append(newDevice)
                connectionChanged = true
                print("New output device detected: \(newDevice.name) - Setting as priority 1")
            }
        }

        // Ensure unique priorities and sort
        inputDevices = ensureUniquePriorities(newInputs)
        outputDevices = ensureUniquePriorities(newOutputs)

        // Update current devices
        currentInputDevice = getCurrentDevice(for: .input)
        currentOutputDevice = getCurrentDevice(for: .output)

        saveDevices()

        // If we have newly connected devices, set them as default immediately
        if !newlyConnectedDevices.isEmpty {
            DispatchQueue.main.async { [weak self] in
                for device in newlyConnectedDevices {
                    if device.isInput {
                        print("Setting new input device as default: \(device.name)")
                        self?.setDevice(device, for: .input)
                    }
                    if device.isOutput {
                        print("Setting new output device as default: \(device.name)")
                        self?.setDevice(device, for: .output)
                    }
                }
            }
        } else if connectionChanged {
            // For reconnected devices, apply priorities after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkAndApplyPriorities()
            }
        }
    }

    private func getSystemAudioDevices() -> [AudioDevice] {
        var devices: [AudioDevice] = []

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        guard status == noErr else { return devices }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var audioDevices = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &audioDevices
        )

        guard status == noErr else { return devices }

        for deviceID in audioDevices {
            if let device = createAudioDevice(from: deviceID) {
                devices.append(device)
            }
        }

        return devices
    }

    private func createAudioDevice(from deviceID: AudioDeviceID) -> AudioDevice? {
        // Get device name
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceName: CFString?
        var dataSize = UInt32(MemoryLayout<CFString?>.size)

        let status = withUnsafeMutablePointer(to: &deviceName) { ptr in
            AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0,
                nil,
                &dataSize,
                ptr
            )
        }

        guard status == noErr, let name = deviceName as String? else { return nil }

        // Get device UID
        propertyAddress.mSelector = kAudioDevicePropertyDeviceUID
        var deviceUID: CFString?
        dataSize = UInt32(MemoryLayout<CFString?>.size)

        _ = withUnsafeMutablePointer(to: &deviceUID) { ptr in
            AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0,
                nil,
                &dataSize,
                ptr
            )
        }

        let uid = (deviceUID as String?) ?? ""

        // Check if device has input/output
        let hasInput = hasStreams(deviceID: deviceID, scope: kAudioDevicePropertyScopeInput)
        let hasOutput = hasStreams(deviceID: deviceID, scope: kAudioDevicePropertyScopeOutput)

        return AudioDevice(
            name: name,
            uid: uid,
            isInput: hasInput,
            isOutput: hasOutput
        )
    }

    private func hasStreams(deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        return status == noErr && dataSize > 0
    }

    private func getCurrentDevice(for type: AudioDeviceType) -> AudioDevice? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: type == .input ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = 0
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceID
        )

        guard status == noErr, deviceID != 0 else { return nil }

        // Get the UID of the current device
        var uidPropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceUID: CFString?
        var uidDataSize = UInt32(MemoryLayout<CFString?>.size)

        let uidStatus = withUnsafeMutablePointer(to: &deviceUID) { ptr in
            AudioObjectGetPropertyData(
                deviceID,
                &uidPropertyAddress,
                0,
                nil,
                &uidDataSize,
                ptr
            )
        }

        guard uidStatus == noErr, let uid = deviceUID as String? else { return nil }

        // Find the device in our saved list
        if type == .input {
            return inputDevices.first(where: { $0.uid == uid })
        } else {
            return outputDevices.first(where: { $0.uid == uid })
        }
    }

    func setDevice(_ device: AudioDevice, for type: AudioDeviceType, isManual: Bool = false) {
        guard device.isEnabled && device.isCurrentlyConnected else { return }

        let deviceID = getDeviceID(for: device.uid)
        guard deviceID != 0 else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: type == .input ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var mutableDeviceID = deviceID
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &mutableDeviceID
        )

        if status == noErr {
            if type == .input {
                currentInputDevice = device
            } else {
                currentOutputDevice = device
            }

            // Mark this as a manual switch if specified
            if isManual {
                lastManualSwitchTime = Date()
            }
        }
    }

    private func getDeviceID(for uid: String) -> AudioDeviceID {
        // First try the direct approach
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var audioDevices = [AudioDeviceID](repeating: 0, count: deviceCount)

        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &audioDevices
        )

        // Search for device with matching UID
        for deviceID in audioDevices {
            var uidPropertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceUID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            var deviceUID: CFString?
            var uidDataSize = UInt32(MemoryLayout<CFString?>.size)

            let status = withUnsafeMutablePointer(to: &deviceUID) { ptr in
                AudioObjectGetPropertyData(
                    deviceID,
                    &uidPropertyAddress,
                    0,
                    nil,
                    &uidDataSize,
                    ptr
                )
            }

            if status == noErr, let currentUID = deviceUID as String?, currentUID == uid {
                return deviceID
            }
        }

        return 0
    }

    private func checkAndApplyPriorities() {
        // Don't auto-switch if we just did a manual switch
        if let lastSwitch = lastManualSwitchTime,
           Date().timeIntervalSince(lastSwitch) < manualSwitchDelay {
            return
        }

        // Check if current devices are still the best available
        // Only switch if there's a better device or current is disconnected

        // Check input devices
        if let currentInput = currentInputDevice {
            // Only switch if current device is disconnected or disabled
            if !currentInput.isCurrentlyConnected || !currentInput.isEnabled {
                if let bestInput = inputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
                    print("Current input disconnected, switching to \(bestInput.name)")
                    setDevice(bestInput, for: .input)
                }
            }
        } else {
            // No current device, set the best one
            if let bestInput = inputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
                print("No current input, setting \(bestInput.name)")
                setDevice(bestInput, for: .input)
            }
        }

        // Check output devices
        if let currentOutput = currentOutputDevice {
            // Only switch if current device is disconnected or disabled
            if !currentOutput.isCurrentlyConnected || !currentOutput.isEnabled {
                if let bestOutput = outputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
                    print("Current output disconnected, switching to \(bestOutput.name)")
                    setDevice(bestOutput, for: .output)
                }
            }
        } else {
            // No current device, set the best one
            if let bestOutput = outputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
                print("No current output, setting \(bestOutput.name)")
                setDevice(bestOutput, for: .output)
            }
        }
    }

    func updateDevicePriority(_ device: AudioDevice, newPriority: Int) {
        if device.isInput {
            if let index = inputDevices.firstIndex(where: { $0.uid == device.uid }) {
                inputDevices[index].priority = newPriority
                inputDevices.sort { $0.priority < $1.priority }
            }
        }

        if device.isOutput {
            if let index = outputDevices.firstIndex(where: { $0.uid == device.uid }) {
                outputDevices[index].priority = newPriority
                outputDevices.sort { $0.priority < $1.priority }
            }
        }

        saveDevices()
        checkAndApplyPriorities()
    }

    func toggleDeviceEnabled(_ device: AudioDevice) {
        objectWillChange.send()

        if device.isInput {
            if let index = inputDevices.firstIndex(where: { $0.uid == device.uid }) {
                inputDevices[index].isEnabled.toggle()
                saveDevices()

                // If we're disabling the current device, switch to next best
                if !inputDevices[index].isEnabled && currentInputDevice?.uid == device.uid {
                    checkAndApplyPriorities()
                }
            }
        }

        if device.isOutput {
            if let index = outputDevices.firstIndex(where: { $0.uid == device.uid }) {
                outputDevices[index].isEnabled.toggle()
                saveDevices()

                // If we're disabling the current device, switch to next best
                if !outputDevices[index].isEnabled && currentOutputDevice?.uid == device.uid {
                    checkAndApplyPriorities()
                }
            }
        }
    }

    func moveDevice(_ device: AudioDevice, direction: MoveDirection) {
        objectWillChange.send()

        if device.isInput {
            guard let currentIndex = inputDevices.firstIndex(where: { $0.uid == device.uid }) else { return }
            let newIndex = direction == .up ? currentIndex - 1 : currentIndex + 1

            guard newIndex >= 0 && newIndex < inputDevices.count else { return }

            // Swap the devices
            inputDevices.swapAt(currentIndex, newIndex)

            // Update priorities
            for (index, _) in inputDevices.enumerated() {
                inputDevices[index].priority = index + 1
            }

            saveDevices()
            checkAndApplyPriorities()
        }

        if device.isOutput {
            guard let currentIndex = outputDevices.firstIndex(where: { $0.uid == device.uid }) else { return }
            let newIndex = direction == .up ? currentIndex - 1 : currentIndex + 1

            guard newIndex >= 0 && newIndex < outputDevices.count else { return }

            // Swap the devices
            outputDevices.swapAt(currentIndex, newIndex)

            // Update priorities
            for (index, _) in outputDevices.enumerated() {
                outputDevices[index].priority = index + 1
            }

            saveDevices()
            checkAndApplyPriorities()
        }
    }

    func reorderInputDevice(from sourceIndex: Int, to destinationIndex: Int) {
        objectWillChange.send()

        guard sourceIndex >= 0 && sourceIndex < inputDevices.count,
              destinationIndex >= 0 && destinationIndex < inputDevices.count else { return }

        // Move the device
        let movedDevice = inputDevices.remove(at: sourceIndex)
        inputDevices.insert(movedDevice, at: destinationIndex)

        // Update all priorities based on new positions
        for (index, _) in inputDevices.enumerated() {
            inputDevices[index].priority = index + 1
        }

        saveDevices()
        checkAndApplyPriorities()
    }

    func reorderOutputDevice(from sourceIndex: Int, to destinationIndex: Int) {
        objectWillChange.send()

        guard sourceIndex >= 0 && sourceIndex < outputDevices.count,
              destinationIndex >= 0 && destinationIndex < outputDevices.count else { return }

        // Move the device
        let movedDevice = outputDevices.remove(at: sourceIndex)
        outputDevices.insert(movedDevice, at: destinationIndex)

        // Update all priorities based on new positions
        for (index, _) in outputDevices.enumerated() {
            outputDevices[index].priority = index + 1
        }

        saveDevices()
        checkAndApplyPriorities()
    }

    func saveDevices() {
        if let inputData = try? JSONEncoder().encode(inputDevices) {
            userDefaults.set(inputData, forKey: "SavedInputDevices")
        }

        if let outputData = try? JSONEncoder().encode(outputDevices) {
            userDefaults.set(outputData, forKey: "SavedOutputDevices")
        }
    }

    private func loadSavedDevices() {
        if let inputData = userDefaults.data(forKey: "SavedInputDevices"),
           let devices = try? JSONDecoder().decode([AudioDevice].self, from: inputData) {
            inputDevices = devices
        }

        if let outputData = userDefaults.data(forKey: "SavedOutputDevices"),
           let devices = try? JSONDecoder().decode([AudioDevice].self, from: outputData) {
            outputDevices = devices
        }
    }

    func resetAllPriorities() {
        // Reset input devices
        for index in inputDevices.indices {
            inputDevices[index].priority = index + 1
        }

        // Reset output devices
        for index in outputDevices.indices {
            outputDevices[index].priority = index + 1
        }

        saveDevices()
        checkAndApplyPriorities()
    }

    func clearDisconnectedDevices() {
        inputDevices = inputDevices.filter { $0.isCurrentlyConnected }
        outputDevices = outputDevices.filter { $0.isCurrentlyConnected }

        // Re-assign priorities
        inputDevices = ensureUniquePriorities(inputDevices)
        outputDevices = ensureUniquePriorities(outputDevices)

        saveDevices()
    }

    private func ensureUniquePriorities(_ devices: [AudioDevice]) -> [AudioDevice] {
        var usedPriorities = Set<Int>()

        for device in devices {
            if usedPriorities.contains(device.priority) {
                // Find next available priority
                var newPriority = 1
                while usedPriorities.contains(newPriority) {
                    newPriority += 1
                }
                device.priority = newPriority
            }
            usedPriorities.insert(device.priority)
        }

        return devices.sorted { $0.priority < $1.priority }
    }

    func updateCheckInterval(_ interval: Double) {
        timer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.checkAndApplyPriorities()
            }
        }
    }

    private func setupGlobalHotkeys() {
        // Remove existing monitor if any
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }

        // Setup global event monitor for keyboard shortcuts
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }

        // Also monitor local events when app is active
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Consume the event
            }
            return event
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        // Get modifiers
        var modifiers: Set<KeyboardShortcut.ModifierKey> = []
        if event.modifierFlags.contains(.command) { modifiers.insert(.command) }
        if event.modifierFlags.contains(.shift) { modifiers.insert(.shift) }
        if event.modifierFlags.contains(.option) { modifiers.insert(.option) }
        if event.modifierFlags.contains(.control) { modifiers.insert(.control) }

        guard !modifiers.isEmpty,
              let characters = event.charactersIgnoringModifiers else {
            return false
        }

        // Check all devices for matching shortcuts
        let allDevices = inputDevices + outputDevices

        for device in allDevices {
            if let shortcut = device.keyboardShortcut,
               shortcut.key.lowercased() == characters.lowercased(),
               shortcut.modifiers == modifiers,
               device.isEnabled && device.isCurrentlyConnected {

                // Switch to this device
                DispatchQueue.main.async { [weak self] in
                    if device.isInput {
                        self?.setDevice(device, for: .input, isManual: true)
                        self?.showNotification(
                            title: "Input Device Changed",
                            subtitle: "Switched to \(device.name)",
                            shortcut: shortcut.displayString
                        )
                        print("Switched input to \(device.name) via keyboard shortcut")
                    }
                    if device.isOutput {
                        self?.setDevice(device, for: .output, isManual: true)
                        self?.showNotification(
                            title: "Output Device Changed",
                            subtitle: "Switched to \(device.name)",
                            shortcut: shortcut.displayString
                        )
                        print("Switched output to \(device.name) via keyboard shortcut")
                    }
                }

                return true // Event handled
            }
        }

        return false
    }

    private func showNotification(title: String, subtitle: String, shortcut: String) {
        // For now, just print to console in debug builds
        print("🔔 \(title): \(subtitle) [\(shortcut)]")

        // Use NSUserNotificationCenter as fallback (deprecated but works)
        if #available(macOS 11.0, *) {
            // Skip notifications in debug for now
        } else {
            let notification = NSUserNotification()
            notification.title = title
            notification.subtitle = subtitle
            notification.informativeText = "Triggered by \(shortcut)"
            notification.soundName = NSUserNotificationDefaultSoundName

            NSUserNotificationCenter.default.deliver(notification)
        }
    }
}

enum MoveDirection {
    case up, down
}

// Audio Device Listener for system changes
class AudioDeviceListener {
    private var listenerBlock: () -> Void

    init(listenerBlock: @escaping () -> Void) {
        self.listenerBlock = listenerBlock
        setupListener()
    }

    private func setupListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            nil,
            { _, _ in
                self.listenerBlock()
            }
        )
    }

    deinit {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectRemovePropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            nil,
            { _, _ in }
        )
    }
}
