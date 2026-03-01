import Cocoa
import SwiftTerm

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController!
    var dropdownWindow: DropdownWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Install the scroll-wheel swizzle so trackpad scrolling works in TUI apps
        installScrollWheelSwizzle()

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

        // Setup global paste monitor
        setupGlobalPasteMonitor()

        // Load saved state
        restoreTerminalSessions()
    }
    
    private func setupGlobalPasteMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                if let window = self?.dropdownWindow, window.isVisible {
                    self?.handleGlobalPaste()
                    return nil // Consume the event
                }
            }
            return event
        }
    }
    
    private func handleGlobalPaste() {
        guard let clipboard = NSPasteboard.general.string(forType: .string) else { return }
        dropdownWindow.tabView.sendTextToCurrentTerminal(clipboard)
    }
    
    func toggleDropdown() {
        if dropdownWindow.isVisible {
            dropdownWindow.slideUp()
        } else {
            positionAndShowWindow()
        }
    }
    
    private func positionAndShowWindow() {
        guard let button = menuBarController.statusItem.button else { return }

        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
        let screenFrame = NSScreen.main?.visibleFrame ?? NSScreen.main?.frame ?? .zero

        // Position: Centered under menu bar icon, clamped to screen edges
        let windowWidth = UserDefaults.standard.windowWidth
        let windowHeight = UserDefaults.standard.windowHeight
        var x = buttonFrame.midX - (windowWidth / 2)
        let y = screenFrame.maxY - windowHeight + screenFrame.origin.y

        // Clamp horizontal position to stay within screen bounds
        let padding: CGFloat = 4
        if x + windowWidth > screenFrame.maxX - padding {
            x = screenFrame.maxX - windowWidth - padding
        }
        if x < screenFrame.minX + padding {
            x = screenFrame.minX + padding
        }

        dropdownWindow.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: false)
        dropdownWindow.slideDown()
    }
    
    private func restoreTerminalSessions() {
        // TODO: Implement session restoration
    }
}