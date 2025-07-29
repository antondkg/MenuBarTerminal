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
        
        // Enable keyboard input
        acceptsMouseMovedEvents = true
        
        // Rounded Corners und Shadow
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 10
        contentView?.layer?.masksToBounds = true
        
        hasShadow = true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override func makeKey() {
        super.makeKey()
        // Ensure terminal gets focus when window becomes key
        if let tabView = contentView as? TerminalTabView {
            DispatchQueue.main.async {
                tabView.focusCurrentTerminal()
            }
        }
    }
    
    override func sendEvent(_ event: NSEvent) {
        // Intercept Cmd+C and Cmd+V before they get processed
        if event.type == .keyDown && event.modifierFlags.contains(.command) {
            if let chars = event.charactersIgnoringModifiers {
                switch chars {
                case "v":
                    performPaste()
                    return // Don't pass this event further
                case "c":
                    performCopy()
                    return // Don't pass this event further
                default:
                    break
                }
            }
        }
        
        super.sendEvent(event)
    }
    
    private func performPaste() {
        guard let clipboard = NSPasteboard.general.string(forType: .string) else { return }
        
        if let tabView = contentView as? TerminalTabView {
            tabView.sendTextToCurrentTerminal(clipboard)
        }
    }
    
    private func performCopy() {
        if let tabView = contentView as? TerminalTabView {
            tabView.copyFromCurrentTerminal()
        }
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
        
        // Auto-hide only on click outside - clean and reliable
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
        }, completionHandler: {
            // Focus auf Terminal nach Animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                self.makeKey()
                if let tabView = self.contentView as? TerminalTabView {
                    tabView.focusCurrentTerminal()
                }
            }
        })
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
    
    deinit {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }
}