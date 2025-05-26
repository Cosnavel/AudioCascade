import Foundation
import CoreAudio
import AVFoundation
import Combine

class AudioDeviceManager: ObservableObject {
    @Published var inputDevices: [AudioDevice] = []
    @Published var outputDevices: [AudioDevice] = []
    @Published var currentInputDevice: AudioDevice?
    @Published var currentOutputDevice: AudioDevice?

    private var audioDeviceListener: AudioDeviceListener?
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard

    init() {
        loadSavedDevices()
        setupAudioDeviceListener()
        refreshDevices()
        startMonitoring()
    }

    deinit {
        timer?.invalidate()
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
        for systemDevice in systemDevices {
            if systemDevice.isInput && !newInputs.contains(where: { $0.uid == systemDevice.uid }) {
                let newDevice = systemDevice
                newDevice.priority = newInputs.count + 1
                newInputs.append(newDevice)
                connectionChanged = true
            }

            if systemDevice.isOutput && !newOutputs.contains(where: { $0.uid == systemDevice.uid }) {
                let newDevice = systemDevice
                newDevice.priority = newOutputs.count + 1
                newOutputs.append(newDevice)
                connectionChanged = true
            }
        }

        // Ensure unique priorities and sort
        inputDevices = ensureUniquePriorities(newInputs)
        outputDevices = ensureUniquePriorities(newOutputs)

        // Update current devices
        currentInputDevice = getCurrentDevice(for: .input)
        currentOutputDevice = getCurrentDevice(for: .output)

        saveDevices()

        // If any device connection changed, immediately apply priorities
        if connectionChanged {
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

        var deviceName: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceName
        )

        guard status == noErr else { return nil }

        let name = deviceName as String

        // Get device UID
        propertyAddress.mSelector = kAudioDevicePropertyDeviceUID
        var deviceUID: CFString = "" as CFString
        dataSize = UInt32(MemoryLayout<CFString>.size)

        AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceUID
        )

        let uid = deviceUID as String

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

        var deviceUID: CFString = "" as CFString
        var uidDataSize = UInt32(MemoryLayout<CFString>.size)

        let uidStatus = AudioObjectGetPropertyData(
            deviceID,
            &uidPropertyAddress,
            0,
            nil,
            &uidDataSize,
            &deviceUID
        )

        guard uidStatus == noErr else { return nil }

        let uid = deviceUID as String

        // Find the device in our saved list
        if type == .input {
            return inputDevices.first(where: { $0.uid == uid })
        } else {
            return outputDevices.first(where: { $0.uid == uid })
        }
    }

    func setDevice(_ device: AudioDevice, for type: AudioDeviceType) {
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

            var deviceUID: CFString = "" as CFString
            var uidDataSize = UInt32(MemoryLayout<CFString>.size)

            let status = AudioObjectGetPropertyData(
                deviceID,
                &uidPropertyAddress,
                0,
                nil,
                &uidDataSize,
                &deviceUID
            )

            if status == noErr && (deviceUID as String) == uid {
                return deviceID
            }
        }

        return 0
    }

    private func checkAndApplyPriorities() {
        // Check input devices
        if let bestInput = inputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
            let currentUID = currentInputDevice?.uid
            if currentUID != bestInput.uid {
                print("Switching input from \(currentInputDevice?.name ?? "none") to \(bestInput.name)")
                setDevice(bestInput, for: .input)
            }
        }

        // Check output devices
        if let bestOutput = outputDevices.first(where: { $0.isEnabled && $0.isCurrentlyConnected }) {
            let currentUID = currentOutputDevice?.uid
            if currentUID != bestOutput.uid {
                print("Switching output from \(currentOutputDevice?.name ?? "none") to \(bestOutput.name)")
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
                checkAndApplyPriorities()
            }
        }

        if device.isOutput {
            if let index = outputDevices.firstIndex(where: { $0.uid == device.uid }) {
                outputDevices[index].isEnabled.toggle()
                saveDevices()
                checkAndApplyPriorities()
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

    private func saveDevices() {
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
        var updatedDevices = devices
        var usedPriorities = Set<Int>()

        for (index, device) in updatedDevices.enumerated() {
            if usedPriorities.contains(device.priority) {
                // Find next available priority
                var newPriority = 1
                while usedPriorities.contains(newPriority) {
                    newPriority += 1
                }
                updatedDevices[index].priority = newPriority
            }
            usedPriorities.insert(updatedDevices[index].priority)
        }

        return updatedDevices.sorted { $0.priority < $1.priority }
    }

    func updateCheckInterval(_ interval: Double) {
        timer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.checkAndApplyPriorities()
            }
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
