# MenuBarTerminal mit SwiftTerm - Vollständiger Projektplan

## 🎯 Projektziel
Ein natives macOS Menu Bar (da wo auch wifi symbol, siri etc sind) Terminal mit Dropdown-Funktionalität, mehreren Tabs und vollständiger Terminal-Funktionalität für Claude Code.

## 📋 Projektübersicht

### Kernfeatures
- Menu Bar Icon mit Dropdown-Terminal
- Mehrere Tabs mit persistenten Sessions
- Smooth Slide-Down/Up Animationen
- Auto-Hide bei Fokus-Verlust
- Volle Kompatibilität mit Claude Code
- Native Performance auf Apple Silicon

### Technologie-Stack
- **Sprache**: Swift 5.9
- **UI Framework**: AppKit (macOS native)
- **Terminal Engine**: SwiftTerm
- **Build System**: Swift Package Manager
- **Min. macOS**: 13.0 (Ventura)

## 🏗 Projektstruktur

```
MenuBarTerminal/
├── Package.swift
├── Sources/
│   └── MenuBarTerminal/
│       ├── main.swift
│       ├── App/
│       │   ├── AppDelegate.swift
│       │   └── AppState.swift
│       ├── UI/
│       │   ├── MenuBarController.swift
│       │   ├── DropdownWindow.swift
│       │   ├── TerminalTabView.swift
│       │   └── PreferencesWindow.swift
│       ├── Terminal/
│       │   ├── TerminalViewController.swift
│       │   ├── TerminalTabManager.swift
│       │   └── TerminalConfig.swift
│       ├── Utils/
│       │   ├── AnimationHelper.swift
│       │   ├── KeyboardShortcuts.swift
│       │   └── UserDefaults+Extension.swift
│       └── Resources/
│           ├── Assets.xcassets/
│           └── Info.plist
└── Tests/
    └── MenuBarTerminalTests/
```

## 📦 Dependencies Setup

### Package.swift
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuBarTerminal",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MenuBarTerminal", targets: ["MenuBarTerminal"])
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.2.3"),
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.15.0")
    ],
    targets: [
        .executableTarget(
            name: "MenuBarTerminal",
            dependencies: [
                "SwiftTerm",
                "KeyboardShortcuts"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MenuBarTerminalTests",
            dependencies: ["MenuBarTerminal"]
        )
    ]
)
```

## 🎨 Implementierungs-Details

### 1. main.swift
```swift
import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // Kein Dock Icon
app.run()
```

### 2. AppDelegate.swift
```swift
import Cocoa
import SwiftTerm

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController!
    var dropdownWindow: DropdownWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu Bar Setup
        menuBarController = MenuBarController()
        
        // Dropdown Window Setup
        dropdownWindow = DropdownWindow()
        
        // Connect Menu Bar to Window
        menuBarController.onToggle = { [weak self] in
            self?.toggleDropdown()
        }
        
        // Setup Global Hotkey (Cmd+Shift+T)
        setupKeyboardShortcuts()
        
        // Load saved state
        restoreTerminalSessions()
    }
    
    private func toggleDropdown() {
        if dropdownWindow.isVisible {
            dropdownWindow.slideUp()
        } else {
            positionAndShowWindow()
        }
    }
    
    private func positionAndShowWindow() {
        guard let button = menuBarController.statusItem.button else { return }
        
        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        // Position: Centered under menu bar icon
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 500
        let x = buttonFrame.midX - (windowWidth / 2)
        let y = screenFrame.maxY - windowHeight - 30 // 30pt unter Menu Bar
        
        dropdownWindow.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: false)
        dropdownWindow.slideDown()
    }
}
```

### 3. MenuBarController.swift
```swift
import Cocoa

class MenuBarController {
    let statusItem: NSStatusItem
    var onToggle: (() -> Void)?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupIcon()
        setupMenu()
    }
    
    private func setupIcon() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Terminal")
            button.action = #selector(toggleClicked)
            button.target = self
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "New Tab", action: #selector(newTab), keyEquivalent: "t")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        statusItem.menu = menu
    }
    
    @objc private func toggleClicked() {
        // Verhindere Menu-Anzeige bei normalem Click
        statusItem.menu = nil
        onToggle?()
        
        // Menu nach kurzer Verzögerung wieder aktivieren (für Right-Click)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupMenu()
        }
    }
    
    @objc private func newTab() {
        NotificationCenter.default.post(name: .newTerminalTab, object: nil)
    }
    
    @objc private func openPreferences() {
        // Preferences implementation
    }
}

extension Notification.Name {
    static let newTerminalTab = Notification.Name("newTerminalTab")
}
```

### 4. DropdownWindow.swift
```swift
import Cocoa

class DropdownWindow: NSWindow {
    private let animationDuration = 0.25
    private var eventMonitor: Any?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupContentView()
        setupEventMonitoring()
    }
    
    private func setupWindow() {
        // Window Eigenschaften
        isOpaque = true
        backgroundColor = NSColor.windowBackgroundColor
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Rounded Corners und Shadow
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 10
        contentView?.layer?.masksToBounds = true
        
        hasShadow = true
    }
    
    private func setupContentView() {
        let tabView = TerminalTabView()
        contentView = tabView
    }
    
    private func setupEventMonitoring() {
        // Auto-hide bei Click außerhalb
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.isVisible else { return }
            
            let clickLocation = event.locationInWindow
            let windowFrame = self.frame
            
            if !windowFrame.contains(clickLocation) {
                self.slideUp()
            }
        }
    }
    
    func slideDown() {
        let finalFrame = frame
        let startFrame = NSRect(x: finalFrame.minX, y: finalFrame.maxY, width: finalFrame.width, height: 0)
        
        setFrame(startFrame, display: false)
        makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(finalFrame, display: true)
            self.animator().alphaValue = 1.0
        })
        
        // Focus auf Terminal
        if let tabView = contentView as? TerminalTabView {
            tabView.focusCurrentTerminal()
        }
    }
    
    func slideUp() {
        let startFrame = frame
        let finalFrame = NSRect(x: startFrame.minX, y: startFrame.maxY, width: startFrame.width, height: 0)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration * 0.8
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(finalFrame, display: true)
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            self.orderOut(nil)
        })
    }
}
```

### 5. TerminalTabView.swift
```swift
import Cocoa
import SwiftTerm

class TerminalTabView: NSView {
    private let tabBar = NSSegmentedControl()
    private let containerView = NSView()
    private var terminals: [TerminalViewController] = []
    private var currentIndex = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        createInitialTab()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Tab Bar Setup
        tabBar.segmentStyle = .texturedRounded
        tabBar.target = self
        tabBar.action = #selector(tabChanged(_:))
        
        // Layout
        addSubview(tabBar)
        addSubview(containerView)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tabBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tabBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            tabBar.heightAnchor.constraint(equalToConstant: 28),
            
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // New Tab Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(createNewTab),
            name: .newTerminalTab,
            object: nil
        )
    }
    
    private func createInitialTab() {
        createNewTab()
    }
    
    @objc private func createNewTab() {
        let terminal = TerminalViewController()
        terminals.append(terminal)
        
        // Update Tab Bar
        tabBar.segmentCount = terminals.count
        tabBar.setLabel("Terminal \(terminals.count)", forSegment: terminals.count - 1)
        tabBar.selectedSegment = terminals.count - 1
        
        // Show new terminal
        showTerminal(at: terminals.count - 1)
    }
    
    @objc private func tabChanged(_ sender: NSSegmentedControl) {
        showTerminal(at: sender.selectedSegment)
    }
    
    private func showTerminal(at index: Int) {
        guard index < terminals.count else { return }
        
        // Remove current
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new
        let terminal = terminals[index]
        containerView.addSubview(terminal.view)
        terminal.view.frame = containerView.bounds
        terminal.view.autoresizingMask = [.width, .height]
        
        currentIndex = index
    }
    
    func focusCurrentTerminal() {
        terminals[currentIndex].focus()
    }
}
```

### 6. TerminalViewController.swift
```swift
import Cocoa
import SwiftTerm

class TerminalViewController: NSViewController {
    private var terminalView: LocalProcessTerminalView!
    private let shellPath = "/bin/zsh"
    
    override func loadView() {
        view = NSView()
        setupTerminal()
    }
    
    private func setupTerminal() {
        terminalView = LocalProcessTerminalView(frame: view.bounds)
        terminalView.autoresizingMask = [.width, .height]
        
        // Terminal Configuration
        terminalView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        terminalView.installColors(TerminalConfig.colorScheme)
        
        // Process starten
        let environment = ProcessInfo.processInfo.environment
        terminalView.startProcess(
            executable: shellPath,
            args: ["-l"], // Login shell
            environment: environment,
            execName: shellPath
        )
        
        view.addSubview(terminalView)
    }
    
    func focus() {
        view.window?.makeFirstResponder(terminalView)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        // Terminal läuft weiter im Hintergrund - keine Aktion nötig
    }
}
```

### 7. TerminalConfig.swift
```swift
import SwiftTerm
import Cocoa

struct TerminalConfig {
    static let colorScheme: [NSColor] = [
        // ANSI Colors (0-15)
        NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),     // Black
        NSColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0),     // Red
        NSColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0),     // Green
        NSColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0),     // Yellow
        NSColor(red: 0.0, green: 0.0, blue: 0.8, alpha: 1.0),     // Blue
        NSColor(red: 0.8, green: 0.0, blue: 0.8, alpha: 1.0),     // Magenta
        NSColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0),     // Cyan
        NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0),     // White
        // Bright colors (8-15)
        NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),     // Bright Black
        NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),     // Bright Red
        NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),     // Bright Green
        NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),     // Bright Yellow
        NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),     // Bright Blue
        NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),     // Bright Magenta
        NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),     // Bright Cyan
        NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),     // Bright White
    ]
    
    static var defaultFont: NSFont {
        return NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    }
}
```

### 8. KeyboardShortcuts.swift
```swift
import Cocoa
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleTerminal = Self("toggleTerminal")
    static let newTab = Self("newTab")
    static let closeTab = Self("closeTab")
}

extension AppDelegate {
    func setupKeyboardShortcuts() {
        // Global Hotkey: Cmd+Shift+T
        KeyboardShortcuts.onKeyUp(for: .toggleTerminal) { [weak self] in
            self?.toggleDropdown()
        }
        
        // Set default shortcuts
        KeyboardShortcuts.setShortcut(.init(.t, modifiers: [.command, .shift]), for: .toggleTerminal)
    }
}
```

## 🧪 Testing Strategy

### Unit Tests
```swift
import XCTest
@testable import MenuBarTerminal

class MenuBarTerminalTests: XCTestCase {
    func testWindowPositioning() {
        let window = DropdownWindow()
        let screenHeight = NSScreen.main?.frame.height ?? 0
        
        XCTAssertEqual(window.frame.maxY, screenHeight - 30)
    }
    
    func testTerminalCreation() {
        let tabView = TerminalTabView()
        tabView.createNewTab()
        
        XCTAssertEqual(tabView.terminals.count, 2) // Initial + new
    }
}
```

### Manual Testing Checklist
- [ ] Menu Bar Icon erscheint korrekt
- [ ] Click öffnet Dropdown smooth
- [ ] Terminal ist voll funktional
- [ ] Claude Code läuft problemlos
- [ ] Tabs funktionieren
- [ ] Auto-Hide bei Fokus-Verlust
- [ ] Keyboard Shortcuts funktionieren
- [ ] Sessions bleiben erhalten
- [ ] Multi-Monitor Support

## 🚀 Build & Run Instructions

```bash
# 1. Projekt erstellen
mkdir MenuBarTerminal && cd MenuBarTerminal
swift package init --type executable

# 2. Package.swift ersetzen mit obiger Version

# 3. Build
swift build

# 4. Run
swift run

# 5. Release Build
swift build -c release
```

## ⚙️ App Bundle Creation

### Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MenuBarTerminal</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.MenuBarTerminal</string>
    <key>CFBundleName</key>
    <string>MenuBarTerminal</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/> <!-- Kein Dock Icon -->
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
```

## 🎨 Erweiterte Features (Optional)

### 1. Themes
```swift
enum Theme: String, CaseIterable {
    case default = "Default"
    case dracula = "Dracula"
    case solarized = "Solarized"
    
    var colors: [NSColor] {
        switch self {
        case .dracula:
            return DraculaTheme.colors
        // etc.
        }
    }
}
```

### 2. Split Panes
```swift
class SplitTerminalView: NSView {
    private var terminals: [TerminalViewController] = []
    private let splitView = NSSplitView()
}
```

### 3. SSH Integration
```swift
func connectSSH(to host: String) {
    terminalView.send("ssh \(host)\r")
}
```

## 🐛 Debugging Tips

### Common Issues & Solutions

1. **Terminal zeigt nichts**
   - Check: `terminalView.startProcess()` wurde aufgerufen
   - Check: Shell path ist korrekt

2. **Window Position falsch**
   - Check: Multi-Monitor Setup
   - Use: `NSScreen.screens` für alle Bildschirme

3. **Performance Issues**
   - Limit: Max 10 Tabs
   - Use: `CALayer` für Animationen

4. **Claude Code funktioniert nicht**
   - Check: Environment Variables werden übergeben
   - Check: Login Shell (`-l` flag)

## 📝 Code Style Guidelines

- Swift API Design Guidelines befolgen
- Meaningful variable names
- Comments für komplexe Logic
- Error handling mit Result types
- Weak references für Closures

## 🎯 Definition of Done

- [ ] Menu Bar Icon mit Toggle funktioniert
- [ ] Dropdown Terminal voll funktional
- [ ] Mehrere Tabs möglich
- [ ] Smooth Animationen
- [ ] Auto-Hide implementiert
- [ ] Claude Code getestet
- [ ] Keyboard Shortcuts aktiv
- [ ] Keine Memory Leaks
- [ ] Release Build erstellt

## 🏁 Final Notes

Dieser Plan deckt alle Aspekte für ein produktionsreifes Menu Bar Terminal ab. Die Implementierung sollte in 3-4 Stunden machbar sein. SwiftTerm übernimmt die schwere Arbeit der Terminal-Emulation, sodass du dich auf die UI und UX konzentrieren kannst.

**Tipp für Claude Code**: Implementiere Feature für Feature und teste nach jedem Schritt. Beginne mit dem absoluten Minimum (Menu Bar Icon + Basic Window) und baue darauf auf.