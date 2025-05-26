# AudioCascade 🎧

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-1.0.0-purple.svg" alt="Version 1.0.0">
</p>

<p align="center">
  <b>The Smart Audio Device Manager for macOS</b><br>
  Never manually switch audio devices again.
</p>

<p align="center">
  <img src="assets/hero-screenshot.png" alt="AudioCascade Hero" width="600">
</p>

## 🚀 The Problem It Solves

Ever plugged in your AirPods and macOS decided to use your webcam microphone instead? Or disconnected your monitor and suddenly you're broadcasting to the void?

**AudioCascade fixes this madness.**

## ✨ Features That Actually Matter

### 🎯 **Priority-Based Switching**
Set your device priorities once. AudioCascade handles the rest.
- Drag & drop to reorder
- Automatic switching to the best available device
- Works for both input and output devices

### 💾 **Device Memory**
AudioCascade remembers every device you've ever connected.
- See disconnected devices grayed out
- Know when you last used each device
- Never lose your settings

### 🚫 **Device Blocking**
Some devices should never be used.
- Disable that terrible webcam mic forever
- Toggle devices on/off with a switch
- Blocked devices are completely ignored

### ⚡ **Real-Time Monitoring**
Instant detection and switching.
- Connects in < 1 second
- No manual intervention needed
- Background monitoring with adjustable intervals

### 🌍 **Multi-Language Support**
Available in:
- 🇬🇧 English
- 🇩🇪 Deutsch
- 🇫🇷 Français

## 📸 Screenshots

<table>
  <tr>
    <td><img src="assets/main-interface.png" alt="Main Interface" width="300"></td>
    <td><img src="assets/priority-drag.png" alt="Priority Management" width="300"></td>
  </tr>
  <tr>
    <td><img src="assets/settings.png" alt="Settings" width="300"></td>
    <td><img src="assets/dark-mode.png" alt="Dark Mode" width="300"></td>
  </tr>
</table>

## 🎮 How It Works

1. **Install & Launch** - AudioCascade lives in your menubar
2. **Set Priorities** - Drag devices to set your preferred order
3. **Forget About It** - AudioCascade automatically switches to the best available device

### Example Setup

**🎤 Input Priority:**
1. Elgato Wave:3 (Professional Mic)
2. AirPods Max (When mobile)
3. MacBook Pro Microphone (Fallback)
4. ❌ Logitech Webcam (Disabled - Never use!)

**🔊 Output Priority:**
1. Studio Monitors (Desktop setup)
2. AirPods Max (Wireless)
3. MacBook Pro Speakers (Built-in)

## 📦 Installation

### Option 1: Download Release (Recommended)
1. Download the latest `.dmg` from [Releases](https://github.com/Cosnavel/AudioCascade/releases)
2. Drag AudioCascade to your Applications folder
3. Launch and enjoy!

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/Cosnavel/AudioCascade.git
cd AudioCascade

# Open in Xcode
open Package.swift

# Build and run (⌘+R)
```

### Option 3: Using Swift CLI
```bash
# Clone and build
git clone https://github.com/Cosnavel/AudioCascade.git
cd AudioCascade
swift build -c release

# Run
.build/release/AudioCascade
```

## 🛠️ Configuration

### Settings
- **Start at Login** - Launch AudioCascade automatically
- **Show in Dock** - Toggle dock icon visibility
- **Check Interval** - Adjust device polling frequency (0.5s - 5.0s)

### Keyboard Shortcuts
- `⌘+,` - Open Settings
- `⌘+Q` - Quit AudioCascade

## 🏗️ Technical Details

### Built With
- **SwiftUI** - Native macOS interface
- **CoreAudio** - Low-level audio device management
- **Combine** - Reactive state management

### Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac

### Permissions
AudioCascade requires no special permissions! It uses public CoreAudio APIs.

## 🤝 Contributing

Found a bug? Have a feature request? Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the frustration of macOS audio device management
- Thanks to the [blog post](https://www.bbss.dev/posts/macos-default-input/) that sparked this project
- Built with ❤️ for the macOS community

## 📬 Support

- 🐛 [Report Issues](https://github.com/Cosnavel/AudioCascade/issues)
- 💬 [Discussions](https://github.com/Cosnavel/AudioCascade/discussions)
- ⭐ Star this repo if you find it useful!

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Cosnavel">Cosnavel</a>
</p>
