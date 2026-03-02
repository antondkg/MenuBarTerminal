import Cocoa

class DropdownWindow: NSWindow {
    private let animationDuration = 0.25
    private let windowCornerRadius: CGFloat = 14
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
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        acceptsMouseMovedEvents = true
        animationBehavior = .utilityWindow
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
        let rootView = NSView()
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.clear.cgColor
        rootView.translatesAutoresizingMaskIntoConstraints = false

        let chromeView = NSVisualEffectView()
        chromeView.material = .underWindowBackground
        chromeView.blendingMode = .withinWindow
        chromeView.state = .active
        chromeView.wantsLayer = true
        chromeView.layer?.cornerRadius = windowCornerRadius
        chromeView.layer?.masksToBounds = true
        chromeView.layer?.borderWidth = 1
        chromeView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.35).cgColor
        chromeView.translatesAutoresizingMaskIntoConstraints = false

        tabView = TerminalTabView()
        let resizeHandle = ResizeHandleView(wrapping: tabView)
        resizeHandle.translatesAutoresizingMaskIntoConstraints = false

        chromeView.addSubview(resizeHandle)
        rootView.addSubview(chromeView)
        contentView = rootView

        NSLayoutConstraint.activate([
            chromeView.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 2),
            chromeView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 2),
            chromeView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -2),
            chromeView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -2),

            resizeHandle.topAnchor.constraint(equalTo: chromeView.topAnchor),
            resizeHandle.leadingAnchor.constraint(equalTo: chromeView.leadingAnchor),
            resizeHandle.trailingAnchor.constraint(equalTo: chromeView.trailingAnchor),
            resizeHandle.bottomAnchor.constraint(equalTo: chromeView.bottomAnchor),
        ])
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
