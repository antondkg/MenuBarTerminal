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
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
            let image = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Terminal")?.withSymbolConfiguration(config)
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageOnly
            button.action = #selector(toggleClicked)
            button.target = self
            
            // Enable right-click for menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "New Tab", action: #selector(newTab), keyEquivalent: "t")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        // Don't set menu by default - we'll handle it manually
    }
    
    @objc private func toggleClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Right click - show menu
            showContextMenu()
        } else {
            // Left click - toggle terminal
            onToggle?()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "New Tab", action: #selector(newTab), keyEquivalent: "t")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        // Set targets
        menu.items.forEach { item in
            if item.action == #selector(newTab) || item.action == #selector(openPreferences) {
                item.target = self
            }
        }
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func newTab() {
        NotificationCenter.default.post(name: .newTerminalTab, object: nil)
    }
    
    @objc private func openPreferences() {
        PreferencesWindow.show()
    }
}

extension Notification.Name {
    static let newTerminalTab = Notification.Name("newTerminalTab")
}
