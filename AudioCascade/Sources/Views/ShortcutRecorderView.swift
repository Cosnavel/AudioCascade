import SwiftUI
import AppKit

struct ShortcutRecorderView: View {
    @Binding var shortcut: KeyboardShortcut?
    @State private var isRecording = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if isRecording {
                    // Recording view
                    HStack(spacing: 4) {
                        Image(systemName: "record.circle")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("shortcut_recording".localized)
                            .font(.caption)
                        Text("(ESC to cancel)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 140, minHeight: 28)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                    .background(
                        ShortcutRecorderNSView(
                            shortcut: $shortcut,
                            isRecording: $isRecording
                        )
                        .frame(width: 1, height: 1)
                        .opacity(0)
                    )
                } else {
                    // Display/Set button
                    Button(action: {
                        isRecording = true
                        isFocused = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "keyboard")
                                .font(.caption)

                            if let shortcut = shortcut {
                                Text(shortcut.displayString)
                                    .font(.system(.caption, design: .monospaced))
                                    .fontWeight(.medium)
                            } else {
                                Text("shortcut_none".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(minWidth: 100)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(shortcut != nil ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(shortcut != nil ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .focused($isFocused)
                }

                if shortcut != nil && !isRecording {
                    Button(action: {
                        shortcut = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("shortcut_clear".localized)
                }
            }

            if shortcut != nil && !isRecording {
                Text("Current: \(shortcut!.displayString)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// NSView wrapper for better keyboard event handling
struct ShortcutRecorderNSView: NSViewRepresentable {
    @Binding var shortcut: KeyboardShortcut?
    @Binding var isRecording: Bool

    func makeNSView(context: Context) -> ShortcutCaptureView {
        let view = ShortcutCaptureView()
        view.onShortcutCaptured = { captured in
            DispatchQueue.main.async {
                self.shortcut = captured
                self.isRecording = false
            }
        }
        view.onCancelled = {
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutCaptureView, context: Context) {
        nsView.isRecording = isRecording
        if isRecording {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }
}

class ShortcutCaptureView: NSView {
    var isRecording = false {
        didSet {
            if isRecording {
                DispatchQueue.main.async { [weak self] in
                    self?.window?.makeFirstResponder(self)
                }
            }
        }
    }
    var onShortcutCaptured: ((KeyboardShortcut) -> Void)?
    var onCancelled: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
    }

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // Check for Escape to cancel
        if event.keyCode == 53 { // Escape key
            onCancelled?()
            return
        }

        var modifiers: Set<KeyboardShortcut.ModifierKey> = []
        if event.modifierFlags.contains(.command) { modifiers.insert(.command) }
        if event.modifierFlags.contains(.shift) { modifiers.insert(.shift) }
        if event.modifierFlags.contains(.option) { modifiers.insert(.option) }
        if event.modifierFlags.contains(.control) { modifiers.insert(.control) }

        if let characters = event.charactersIgnoringModifiers,
           !characters.isEmpty,
           !modifiers.isEmpty {
            let shortcut = KeyboardShortcut(key: characters, modifiers: modifiers)
            onShortcutCaptured?(shortcut)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        // Handle modifier-only shortcuts if needed in the future
        super.flagsChanged(with: event)
    }
}
