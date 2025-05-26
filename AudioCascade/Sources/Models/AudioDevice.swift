import Foundation
import CoreAudio

class AudioDevice: Identifiable, Codable, Equatable, Hashable, ObservableObject {
    let id: UUID
    let name: String
    let uid: String
    let isInput: Bool
    let isOutput: Bool
    @Published var priority: Int
    @Published var isEnabled: Bool
    @Published var lastSeen: Date
    @Published var isCurrentlyConnected: Bool

    init(name: String, uid: String, isInput: Bool, isOutput: Bool, priority: Int = Int.max, isEnabled: Bool = true, lastSeen: Date = Date(), isCurrentlyConnected: Bool = true) {
        self.id = UUID()
        self.name = name
        self.uid = uid
        self.isInput = isInput
        self.isOutput = isOutput
        self.priority = priority
        self.isEnabled = isEnabled
        self.lastSeen = lastSeen
        self.isCurrentlyConnected = isCurrentlyConnected
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, uid, isInput, isOutput, priority, isEnabled, lastSeen, isCurrentlyConnected
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        uid = try container.decode(String.self, forKey: .uid)
        isInput = try container.decode(Bool.self, forKey: .isInput)
        isOutput = try container.decode(Bool.self, forKey: .isOutput)
        priority = try container.decode(Int.self, forKey: .priority)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        lastSeen = try container.decode(Date.self, forKey: .lastSeen)
        isCurrentlyConnected = try container.decode(Bool.self, forKey: .isCurrentlyConnected)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(uid, forKey: .uid)
        try container.encode(isInput, forKey: .isInput)
        try container.encode(isOutput, forKey: .isOutput)
        try container.encode(priority, forKey: .priority)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(lastSeen, forKey: .lastSeen)
        try container.encode(isCurrentlyConnected, forKey: .isCurrentlyConnected)
    }

    static func == (lhs: AudioDevice, rhs: AudioDevice) -> Bool {
        lhs.uid == rhs.uid && lhs.isInput == rhs.isInput && lhs.isOutput == rhs.isOutput
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(isInput)
        hasher.combine(isOutput)
    }
}

enum AudioDeviceType: String, CaseIterable {
    case input = "Input"
    case output = "Output"

    var systemSymbol: String {
        switch self {
        case .input:
            return "mic"
        case .output:
            return "speaker.wave.2"
        }
    }
}
