import Cocoa

class DropdownWindow: NSWindow {
    private let animationDuration = 0.25
    private var clickMonitor: Any?
    private(set) var tabView: TerminalTabView!

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
        isOpaque = true
        backgroundColor = NSColor.windowBackgroundColor
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        acceptsMouseMovedEvents = true

        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 10
        contentView?.layer?.masksToBounds = true

        hasShadow = true
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown && event.modifierFlags.contains(.command) {
            if let chars = event.charactersIgnoringModifiers {
                switch chars {
                case "v":
                    performPaste()
                    return
                case "c":
                    performCopy()
                    return
                default:
                    break
                }
            }
        }

        super.sendEvent(event)
    }

    private func performPaste() {
        guard let clipboard = NSPasteboard.general.string(forType: .string) else { return }
        tabView.sendTextToCurrentTerminal(clipboard)
    }

    private func performCopy() {
        tabView.copyFromCurrentTerminal()
    }

    private func setupContentView() {
        tabView = TerminalTabView()
        let resizeHandle = ResizeHandleView(wrapping: tabView)
        contentView = resizeHandle

        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 10
        contentView?.layer?.masksToBounds = true
    }

    private func setupEventMonitoring() {
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.isVisible else { return }
            if !self.frame.contains(event.locationInWindow) {
                self.slideUp()
            }
        }
    }

    func slideDown() {
        let finalFrame = frame
        let startFrame = NSRect(
            x: finalFrame.minX,
            y: finalFrame.origin.y + 20,
            width: finalFrame.width,
            height: finalFrame.height
        )

        alphaValue = 0
        setFrame(startFrame, display: false)
        orderFrontRegardless()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(finalFrame, display: true)
            self.animator().alphaValue = 1.0
        }, completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                self.makeKeyAndOrderFront(nil)
                self.tabView.focusCurrentTerminal()
            }
        })
    }

    func slideUp() {
        let startFrame = frame
        let finalFrame = NSRect(
            x: startFrame.minX,
            y: startFrame.origin.y + 20,
            width: startFrame.width,
            height: startFrame.height
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration * 0.8
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(finalFrame, display: true)
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            self.orderOut(nil)
            self.setFrame(startFrame, display: false)
        })
    }

    deinit {
        if let clickMonitor = clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
        }
    }
}
