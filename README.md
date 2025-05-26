# AudioCascade 🎧

A beautiful macOS menubar app for intelligent audio device management with priority-based switching.

![AudioCascade](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features ✨

- 🎯 **Priority-based device switching** - Set your preferred device order
- 💾 **Device memory** - Remembers all devices even when disconnected
- 🚫 **Device blocking** - Disable devices you never want to use
- 🔄 **Automatic switching** - Switches to highest priority available device
- 🎨 **Beautiful native UI** - Modern macOS design with SwiftUI
- 🔍 **Device search** - Quickly find devices in long lists
- ⚡ **Real-time monitoring** - Instant detection of device changes

## How It Works 🛠️

1. **Set Priorities**: Drag devices to reorder them by priority (1 = highest)
2. **Enable/Disable**: Toggle devices on/off to control which can be used
3. **Auto-Switch**: AudioCascade automatically selects the highest priority enabled device
4. **Remember Devices**: All devices are remembered even when disconnected

## Example Setup 📋

**Input Priority:**
1. 🎙️ Elgato Wave:3 (when available)
2. 🎧 AirPods Max (backup)
3. 💻 MacBook Pro Microphone (fallback)
4. ❌ Logitech Camera (disabled - never use)

**Output Priority:**
1. 🔊 Studio Monitors (when available)
2. 🎧 AirPods Max (when mobile)
3. 💻 MacBook Pro Speakers (fallback)

## Installation 📦

### From Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/AudioCascade.git
cd AudioCascade
```

2. Open in Xcode:
```bash
open Package.swift
```

3. Build and run (⌘+R)

### Direct Download

Coming soon: Download the latest `.dmg` from the [Releases](https://github.com/yourusername/AudioCascade/releases) page.

## Usage 🚀

1. Click the menubar icon to open AudioCascade
2. Switch between Input/Output tabs
3. Drag devices to reorder priorities
4. Toggle devices on/off with the switch
5. Right-click for more options

## Requirements 📱

- macOS 13.0 or later
- Apple Silicon or Intel Mac

## Development 👨‍💻

### Architecture

- **SwiftUI** for the user interface
- **CoreAudio** for device management
- **Combine** for reactive updates
- **UserDefaults** for persistence

### Building

```bash
swift build
swift run
```

### Testing

```bash
swift test
```

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- Inspired by the frustration of macOS audio device switching
- Built with love for the macOS community
- Thanks to the [blog post](https://www.bbss.dev/posts/macos-default-input/) that sparked this idea

---

Made with ❤️ by [Your Name]
