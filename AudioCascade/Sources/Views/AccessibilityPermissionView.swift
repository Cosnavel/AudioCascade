import SwiftUI
import AppKit

struct AccessibilityPermissionView: View {
    @Binding var isPresented: Bool
    @State private var animateIcon = false

    var body: some View {
        VStack(spacing: 24) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)

                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
            .onAppear { animateIcon = true }

            // Title
            Text("permission_title".localized)
                .font(.title2)
                .fontWeight(.semibold)

            // Description
            VStack(spacing: 12) {
                Text("permission_description".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 350)

                HStack(spacing: 16) {
                    FeatureItem(icon: "keyboard", text: "permission_feature_shortcuts".localized)
                    FeatureItem(icon: "globe", text: "permission_feature_global".localized)
                    FeatureItem(icon: "lock.shield", text: "permission_feature_secure".localized)
                }
                .padding(.vertical, 8)
            }

            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("permission_instructions".localized)
                    .font(.caption)
                    .fontWeight(.medium)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "1.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text("permission_step1".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "2.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text("permission_step2".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "3.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text("permission_step3".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .frame(maxWidth: 350)

            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "accessibilityPermissionDismissed")
                    isPresented = false
                }) {
                    Text("permission_later".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .controlSize(.large)

                Button(action: {
                    openAccessibilitySettings()
                    isPresented = false
                }) {
                    Text("permission_open_settings".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(24)
        .frame(width: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)

        // Also trigger the system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
