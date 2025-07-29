# MenuBarTerminal

A native macOS menu bar terminal application with dropdown functionality, multiple tabs, and full terminal capabilities. Perfect for developers who want quick terminal access without cluttering their dock.

![MenuBarTerminal Demo](demo.gif)

## ✨ Features

- 🎯 **Menu Bar Integration**: Clean menu bar icon with dropdown terminal
- 📱 **Multiple Tabs**: Support for multiple terminal sessions with easy tab management
- ✨ **Smooth Animations**: Beautiful slide-down/up animations with native feel
- 🔄 **Auto-Hide**: Automatically hides when clicking outside (configurable)
- ⚡ **Global Hotkey**: Quick access with `Cmd+Shift+T`
- 📁 **Custom Directory**: Set your preferred startup directory
- 🚀 **Autostart**: Optional startup at login
- 📋 **Copy/Paste**: Full clipboard support (`Cmd+C`/`Cmd+V`)
- 🧠 **Claude Code Compatible**: Works seamlessly with Claude Code CLI
- 🍎 **Native Performance**: Built with Swift and AppKit for optimal macOS experience

## 🎯 Perfect for

- **Developers** who need quick terminal access
- **Claude Code users** wanting integrated terminal experience  
- **Power users** who prefer menu bar tools
- Anyone wanting a **clean, minimal terminal** solution

## 📋 Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later (for building from source)

## 🚀 Installation

### Option 1: Download Release (Coming Soon)
Download the latest `.dmg` from [Releases](../../releases)

### Option 2: Build from Source

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/MenuBarTerminal.git
   cd MenuBarTerminal
   ```

2. **Build the project:**
   ```bash
   swift build -c release
   ```

3. **Run the application:**
   ```bash
   .build/release/MenuBarTerminal
   ```

## 🎮 Usage

### Basic Operations
- **Toggle Terminal**: Click menu bar icon or press `Cmd+Shift+T`
- **New Tab**: Right-click menu bar icon → "New Tab"
- **Close Tab**: Click the `✕` on tab titles (when multiple tabs open)
- **Switch Tabs**: Click on tab titles
- **Hide Terminal**: Click outside terminal window

### Preferences
Right-click menu bar icon → **Preferences** to configure:
- **Font Size**: Adjust terminal font size
- **Window Size**: Set custom width/height
- **Default Directory**: Choose startup directory
- **Auto-hide**: Enable/disable auto-hide on focus loss
- **Global Hotkey**: Enable/disable `Cmd+Shift+T`
- **Autostart**: Launch at login

### Keyboard Shortcuts
- `Cmd+Shift+T`: Toggle terminal visibility
- `Cmd+C`: Copy selected text
- `Cmd+V`: Paste from clipboard
- `Cmd+T`: New tab (from right-click menu)

## 🏗 Architecture

```
MenuBarTerminal/
├── Sources/MenuBarTerminal/
│   ├── main.swift                 # Application entry point
│   ├── App/                       # App lifecycle & state
│   │   ├── AppDelegate.swift      # Main app coordinator
│   │   └── AppState.swift         # Shared app state
│   ├── UI/                        # User interface
│   │   ├── MenuBarController.swift    # Menu bar management
│   │   ├── DropdownWindow.swift       # Main terminal window
│   │   ├── TerminalTabView.swift      # Tab management
│   │   └── PreferencesWindow.swift    # Settings window
│   ├── Terminal/                  # Terminal logic
│   │   ├── TerminalViewController.swift  # Individual terminal
│   │   ├── TerminalConfig.swift         # Terminal configuration
│   │   └── TerminalTabManager.swift     # Tab state management
│   └── Utils/                     # Utilities
│       ├── KeyboardShortcuts.swift     # Global hotkeys
│       ├── AnimationHelper.swift       # Animation utilities
│       └── UserDefaults+Extension.swift # Settings storage
├── Tests/                         # Unit tests
├── Package.swift                  # Swift Package Manager
├── LICENSE                        # MIT License
└── README.md                      # This file
```

## 🔧 Technical Details

### Dependencies
- **[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)**: Terminal emulation engine
- **Carbon**: Global hotkey registration
- **AppKit**: Native macOS UI framework

### Terminal Features
- Full ANSI color support (16 colors)
- Login shell support with environment inheritance
- Persistent sessions (continue running when hidden)
- Text selection and clipboard integration
- Mouse support for text selection

## 🧪 Development

### Building
```bash
# Debug build
swift build

# Release build  
swift build -c release

# Run directly during development
swift run
```

### Testing
```bash
# Run tests
swift test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Troubleshooting

### Common Issues

**Terminal doesn't appear**
- Check that the menu bar icon is visible
- Try clicking the icon or pressing `Cmd+Shift+T`

**Global hotkey not working**
- Go to System Preferences → Security & Privacy → Accessibility
- Add MenuBarTerminal to the list of allowed apps

**Commands not found**
- Check that your shell environment is properly configured
- Terminal uses login shell (`-l` flag) to inherit your environment

**Copy/paste not working**
- Make sure to select text first, then use `Cmd+C`
- Use `Cmd+V` to paste (not right-click paste)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)** by Miguel de Icaza - Excellent terminal emulation library
- **Apple's AppKit** - Native macOS interface framework
- **The Swift Community** - Ongoing support and development
- **Claude Code** - Inspiration for terminal integration

## 🗺 Roadmap

### Planned Features
- [ ] **App Bundle**: Native `.app` bundle for easy installation
- [ ] **Themes**: Dark mode and custom color schemes
- [ ] **Split Panes**: Multiple terminals in one window
- [ ] **SSH Integration**: Quick SSH connection management
- [ ] **Session Restoration**: Remember terminals across app restarts
- [ ] **Custom Shortcuts**: User-configurable keyboard shortcuts
- [ ] **Shell Profiles**: Multiple shell configurations

### Maybe Features
- [ ] **Touch Bar Support**: MacBook Pro Touch Bar integration
- [ ] **Script Integration**: Run custom scripts from menu
- [ ] **Terminal History**: Search through terminal history
- [ ] **Notification Integration**: Terminal notifications

---

**Made with ❤️ for developers who love clean, efficient tools.**