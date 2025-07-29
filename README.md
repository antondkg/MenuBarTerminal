# MenuBarTerminal

A native macOS menu bar terminal application with dropdown functionality, multiple tabs, and full terminal capabilities designed to work seamlessly with Claude Code.

## Features

- 🎯 **Menu Bar Integration**: Clean menu bar icon with dropdown terminal
- 📱 **Multiple Tabs**: Support for multiple terminal sessions
- ✨ **Smooth Animations**: Beautiful slide-down/up animations
- 🔄 **Auto-Hide**: Automatically hides when focus is lost
- ⚡ **Global Hotkey**: Quick access with Cmd+Shift+T
- 🧠 **Claude Code Compatible**: Full compatibility with Claude Code CLI
- 🍎 **Native Performance**: Built with Swift and AppKit for optimal macOS experience

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later

## Installation

### Building from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/NoahSchmitd/MenuBarTerminal.git
   cd MenuBarTerminal
   ```

2. Build the project:
   ```bash
   swift build -c release
   ```

3. Run the application:
   ```bash
   .build/release/MenuBarTerminal
   ```

## Usage

### Basic Operations

- **Open/Close Terminal**: Click the terminal icon in the menu bar or press `Cmd+Shift+T`
- **New Tab**: Right-click the menu bar icon and select "New Tab" or use the menu
- **Switch Tabs**: Click on tab titles in the terminal interface
- **Auto-Hide**: Click outside the terminal window to hide it automatically

### Global Hotkeys

- `Cmd+Shift+T`: Toggle terminal visibility

### Menu Options

Right-click the menu bar icon to access:
- New Tab
- Preferences (coming soon)
- Quit

## Architecture

The project follows a clean architecture pattern:

```
MenuBarTerminal/
├── App/                    # Application lifecycle
├── UI/                     # User interface components
├── Terminal/               # Terminal-specific logic
├── Utils/                  # Utility functions and extensions
└── Resources/              # Assets and resources
```

### Key Components

- **AppDelegate**: Main application coordinator
- **MenuBarController**: Manages the menu bar icon and menu
- **DropdownWindow**: Handles the dropdown terminal window with animations
- **TerminalTabView**: Manages multiple terminal tabs
- **TerminalViewController**: Individual terminal instances using SwiftTerm

## Technical Details

### Dependencies

- **SwiftTerm**: Provides terminal emulation capabilities
- **Carbon**: Used for global hotkey registration

### Terminal Features

- Full ANSI color support (16 colors)
- Login shell support (`-l` flag)
- Environment variable inheritance
- Persistent sessions (terminals continue running when hidden)

## Development

### Project Structure

The codebase is organized into logical modules:

1. **App Layer**: Application state and lifecycle management
2. **UI Layer**: User interface components and controllers  
3. **Terminal Layer**: Terminal emulation and session management
4. **Utils Layer**: Helper functions and extensions

### Building

```bash
# Debug build
swift build

# Release build  
swift build -c release

# Run directly
swift run
```

## Testing with Claude Code

The terminal is designed to work seamlessly with Claude Code:

1. Install Claude Code CLI in your system
2. Open MenuBarTerminal
3. Use Claude Code commands as normal - all features should work including:
   - File operations
   - Code execution
   - Interactive sessions
   - Environment variables

## Troubleshooting

### Common Issues

1. **Terminal doesn't appear**: Check that the menu bar icon is visible and clickable
2. **Global hotkey not working**: Ensure the app has accessibility permissions in System Preferences
3. **Commands not found**: Verify that your shell environment is properly configured

### Permissions

The application may require:
- **Accessibility Access**: For global hotkeys (System Preferences > Security & Privacy > Accessibility)

## Contributing

1. Fork the project
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

**This application is built on top of excellent open source libraries:**

- **[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)** by Miguel de Icaza - The core terminal emulation engine that powers this app. All terminal functionality (text rendering, ANSI color support, shell interaction) is provided by SwiftTerm.
- **Apple's AppKit** - Native macOS interface framework for window management and UI components
- **Swift Package Manager** - Dependency management and build system
- **The Swift Community** - Ongoing support and development

**Important Note:** This application is a GUI wrapper around SwiftTerm. The actual terminal emulation, text processing, and shell interaction are handled entirely by the SwiftTerm library. We've built the menu bar interface, dropdown animations, tab management, and preferences system on top of SwiftTerm's solid foundation.

## Roadmap

- [ ] Preferences window with customizable settings
- [ ] Theme support (Dark mode, custom color schemes)
- [ ] Split pane functionality
- [ ] SSH connection management
- [ ] Session restoration across app restarts
- [ ] Custom keyboard shortcuts configuration
- [ ] Shell profile selection
- [ ] Mous youse insted of arrow keys