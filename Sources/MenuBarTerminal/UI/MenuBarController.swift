import Cocoa

class MenuBarController {
    let statusItem: NSStatusItem
    var onToggle: (() -> Void)?
    private var normalIcon: NSImage?
    private var attentionIcon: NSImage?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupIcon()
        setupMenu()
    }
    
    private func setupIcon() {
        if let button = statusItem.button {
            normalIcon = makeStatusIcon(symbols: ["terminal"], accessibilityDescription: "Terminal")
            attentionIcon = makeStatusIcon(
                symbols: ["terminal.badge.exclamationmark", "bell.badge.fill", "bell.fill"],
                accessibilityDescription: "Terminal attention"
            )
            button.image = normalIcon
            button.imagePosition = .imageOnly
            button.action = #selector(toggleClicked)
            button.target = self
            
            // Enable right-click for menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func makeStatusIcon(symbols: [String], accessibilityDescription: String) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        for symbol in symbols {
            if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: accessibilityDescription)?.withSymbolConfiguration(config) {
                image.isTemplate = true
                return image
            }
        }
        return nil
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
        setAttentionIndicator(false)
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

    func setAttentionIndicator(_ enabled: Bool) {
        guard let button = statusItem.button else { return }
        button.image = enabled ? (attentionIcon ?? normalIcon) : normalIcon
    }
}

extension Notification.Name {
    static let newTerminalTab = Notification.Name("newTerminalTab")
    static let terminalAttention = Notification.Name("terminalAttention")
}
