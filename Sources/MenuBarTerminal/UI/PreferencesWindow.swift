import Cocoa
import ServiceManagement

class PreferencesWindow: NSWindow {
    private static var sharedInstance: PreferencesWindow?
    
    static func show() {
        if sharedInstance == nil {
            sharedInstance = PreferencesWindow()
        }
        sharedInstance?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupContentView()
        center()
    }
    
    private func setupWindow() {
        title = "MenuBarTerminal Preferences"
        titlebarAppearsTransparent = true
        toolbarStyle = .preference
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
    }
    
    private func setupContentView() {
        let chromeView = NSVisualEffectView()
        chromeView.material = .sidebar
        chromeView.blendingMode = .withinWindow
        chromeView.state = .active
        chromeView.wantsLayer = true
        chromeView.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.8).cgColor

        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 12
        containerView.layer?.masksToBounds = true
        containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.92).cgColor
        containerView.layer?.borderWidth = 1
        containerView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.35).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        chromeView.addSubview(containerView)
        contentView = chromeView

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: chromeView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: chromeView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: chromeView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: chromeView.bottomAnchor, constant: -16),
        ])
        
        // Title Label
        let titleLabel = NSTextField(labelWithString: "MenuBarTerminal Settings")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        
        // Font Size
        let fontLabel = NSTextField(labelWithString: "Font Size:")
        let fontSlider = NSSlider()
        fontSlider.minValue = 10
        fontSlider.maxValue = 24
        fontSlider.doubleValue = Double(UserDefaults.standard.fontSize)
        
        // Window Size
        let widthLabel = NSTextField(labelWithString: "Window Width:")
        let widthField = NSTextField()
        widthField.stringValue = String(Int(UserDefaults.standard.windowWidth))
        
        let heightLabel = NSTextField(labelWithString: "Window Height:")
        let heightField = NSTextField()
        heightField.stringValue = String(Int(UserDefaults.standard.windowHeight))
        
        // Auto Hide
        let autoHideButton = NSButton(checkboxWithTitle: "Auto-hide when losing focus", target: nil, action: nil)
        autoHideButton.state = UserDefaults.standard.autoHide ? .on : .off
        
        // Global Hotkey
        let hotkeyButton = NSButton(checkboxWithTitle: "Enable global hotkey (Cmd+Shift+T)", target: nil, action: nil)
        hotkeyButton.state = UserDefaults.standard.globalHotkeyEnabled ? .on : .off
        
        // Autostart
        let autostartButton = NSButton(checkboxWithTitle: "Start at login", target: nil, action: nil)
        autostartButton.state = UserDefaults.standard.autostartEnabled ? .on : .off
        
        // Default Directory
        let directoryLabel = NSTextField(labelWithString: "Default Directory:")
        let directoryField = NSTextField()
        directoryField.stringValue = UserDefaults.standard.defaultDirectory
        directoryField.isEditable = false
        
        let browseButton = NSButton(title: "Browse...", target: self, action: #selector(browseDirectory))
        
        let directoryStack = NSStackView(views: [directoryField, browseButton])
        directoryStack.orientation = .horizontal
        directoryStack.spacing = 8
        
        // Buttons
        let saveButton = NSButton(title: "Save", target: self, action: #selector(savePreferences))
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelPreferences))
        
        // Layout
        let stackView = NSStackView(views: [
            titleLabel,
            NSView(), // Spacer
            fontLabel,
            fontSlider,
            NSView(), // Spacer
            widthLabel,
            widthField,
            heightLabel,
            heightField,
            NSView(), // Spacer
            directoryLabel,
            directoryStack,
            NSView(), // Spacer
            autoHideButton,
            hotkeyButton,
            autostartButton,
            NSView(), // Spacer
            NSStackView(views: [cancelButton, saveButton])
        ])
        
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ])
        
        // Store references for saving
        self.fontSlider = fontSlider
        self.widthField = widthField
        self.heightField = heightField
        self.autoHideButton = autoHideButton
        self.hotkeyButton = hotkeyButton
        self.autostartButton = autostartButton
        self.directoryField = directoryField
    }
    
    // Store UI elements for access in save method
    private var fontSlider: NSSlider!
    private var widthField: NSTextField!
    private var heightField: NSTextField!
    private var autoHideButton: NSButton!
    private var hotkeyButton: NSButton!
    private var autostartButton: NSButton!
    private var directoryField: NSTextField!
    
    @objc private func savePreferences() {
        UserDefaults.standard.fontSize = CGFloat(fontSlider.doubleValue)
        UserDefaults.standard.windowWidth = CGFloat(Double(widthField.stringValue) ?? 800)
        UserDefaults.standard.windowHeight = CGFloat(Double(heightField.stringValue) ?? 500)
        UserDefaults.standard.autoHide = autoHideButton.state == .on
        UserDefaults.standard.globalHotkeyEnabled = hotkeyButton.state == .on
        UserDefaults.standard.autostartEnabled = autostartButton.state == .on
        UserDefaults.standard.defaultDirectory = directoryField.stringValue
        
        // Handle autostart setting
        updateAutostartSetting()
        
        close()
        
        // Show confirmation
        let alert = NSAlert()
        alert.messageText = "Preferences Saved"
        alert.informativeText = "Some changes may require restarting the application."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func browseDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = URL(fileURLWithPath: UserDefaults.standard.defaultDirectory)
        
        if openPanel.runModal() == .OK {
            if let selectedURL = openPanel.url {
                directoryField.stringValue = selectedURL.path
            }
        }
    }
    
    private func updateAutostartSetting() {
        let service = SMAppService.mainApp
        do {
            if UserDefaults.standard.autostartEnabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            print("Failed to update login item: \(error)")
        }
    }
    
    @objc private func cancelPreferences() {
        close()
    }
}
