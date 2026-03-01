import Cocoa

class ResizeHandleView: NSView {
    private static let edgeThickness: CGFloat = 8
    private static let minWidth: CGFloat = 400
    private static let minHeight: CGFloat = 300

    private var dragEdge: Edge = .none
    private var dragStartPoint: NSPoint = .zero
    private var dragStartFrame: NSRect = .zero
    private let gripView = ResizeGripView()

    private enum Edge {
        case none, left, right, bottom, bottomLeft, bottomRight
    }

    let wrappedView: NSView

    init(wrapping view: NSView) {
        self.wrappedView = view
        super.init(frame: .zero)
        addSubview(wrappedView)
        addSubview(gripView)

        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        gripView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrappedView.topAnchor.constraint(equalTo: topAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrappedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: bottomAnchor),

            gripView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            gripView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            gripView.widthAnchor.constraint(equalToConstant: 14),
            gripView.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hit Testing

    override func hitTest(_ point: NSPoint) -> NSView? {
        let local = convert(point, from: superview)
        if edgeAt(local) != .none {
            return self
        }
        return super.hitTest(point)
    }

    private func edgeAt(_ point: NSPoint) -> Edge {
        let t = ResizeHandleView.edgeThickness
        let w = bounds.width
        let h = bounds.height

        let onLeft = point.x < t
        let onRight = point.x > w - t
        let onBottom = point.y < t
        // Don't claim the top 50pt — that's the tab bar / toolbar area
        let inTopBar = point.y > h - 50

        if inTopBar { return .none }
        if onBottom && onLeft { return .bottomLeft }
        if onBottom && onRight { return .bottomRight }
        if onBottom { return .bottom }
        if onLeft { return .left }
        if onRight { return .right }
        return .none
    }

    // MARK: - Cursor

    override func cursorUpdate(with event: NSEvent) {
        let local = convert(event.locationInWindow, from: nil)
        let edge = edgeAt(local)
        if edge != .none {
            cursorForEdge(edge).set()
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }

        let t = ResizeHandleView.edgeThickness

        // Bottom edge
        addEdgeTrackingArea(NSRect(x: t, y: 0, width: bounds.width - 2 * t, height: t))
        // Left edge
        addEdgeTrackingArea(NSRect(x: 0, y: t, width: t, height: bounds.height - t))
        // Right edge
        addEdgeTrackingArea(NSRect(x: bounds.width - t, y: t, width: t, height: bounds.height - t))
        // Bottom-left corner
        addEdgeTrackingArea(NSRect(x: 0, y: 0, width: t, height: t))
        // Bottom-right corner
        addEdgeTrackingArea(NSRect(x: bounds.width - t, y: 0, width: t, height: t))
    }

    private func addEdgeTrackingArea(_ rect: NSRect) {
        guard rect.width > 0 && rect.height > 0 else { return }
        let area = NSTrackingArea(
            rect: rect,
            options: [.cursorUpdate, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }

    private func cursorForEdge(_ edge: Edge) -> NSCursor {
        switch edge {
        case .left, .right:
            return NSCursor.resizeLeftRight
        case .bottom, .bottomLeft, .bottomRight:
            return NSCursor.resizeUpDown
        case .none:
            return NSCursor.arrow
        }
    }

    // MARK: - Drag to Resize

    override func mouseDown(with event: NSEvent) {
        let local = convert(event.locationInWindow, from: nil)
        dragEdge = edgeAt(local)
        if dragEdge == .none {
            super.mouseDown(with: event)
            return
        }
        cursorForEdge(dragEdge).set()
        dragStartPoint = NSEvent.mouseLocation
        dragStartFrame = window?.frame ?? .zero
    }

    override func mouseDragged(with event: NSEvent) {
        guard dragEdge != .none, let win = window else {
            super.mouseDragged(with: event)
            return
        }

        cursorForEdge(dragEdge).set()

        let current = NSEvent.mouseLocation
        let dx = current.x - dragStartPoint.x
        let dy = current.y - dragStartPoint.y

        var newFrame = dragStartFrame
        let minW = ResizeHandleView.minWidth
        let minH = ResizeHandleView.minHeight

        let topEdge = dragStartFrame.maxY

        switch dragEdge {
        case .right:
            newFrame.size.width = max(dragStartFrame.width + dx, minW)
        case .left:
            let proposedWidth = max(dragStartFrame.width - dx, minW)
            newFrame.origin.x = dragStartFrame.maxX - proposedWidth
            newFrame.size.width = proposedWidth
        case .bottom:
            let proposedHeight = max(dragStartFrame.height - dy, minH)
            newFrame.size.height = proposedHeight
            newFrame.origin.y = topEdge - proposedHeight
        case .bottomLeft:
            let proposedWidth = max(dragStartFrame.width - dx, minW)
            newFrame.origin.x = dragStartFrame.maxX - proposedWidth
            newFrame.size.width = proposedWidth
            let proposedHeight = max(dragStartFrame.height - dy, minH)
            newFrame.size.height = proposedHeight
            newFrame.origin.y = topEdge - proposedHeight
        case .bottomRight:
            newFrame.size.width = max(dragStartFrame.width + dx, minW)
            let proposedHeight = max(dragStartFrame.height - dy, minH)
            newFrame.size.height = proposedHeight
            newFrame.origin.y = topEdge - proposedHeight
        case .none:
            break
        }

        win.setFrame(newFrame, display: true)
    }

    override func mouseUp(with event: NSEvent) {
        if dragEdge != .none, let win = window {
            UserDefaults.standard.windowWidth = win.frame.width
            UserDefaults.standard.windowHeight = win.frame.height
        }
        dragEdge = .none
        NSCursor.arrow.set()
    }
}

// MARK: - Resize Grip (bottom-right visual indicator)

private class ResizeGripView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Pass through to parent ResizeHandleView for hit testing
        return nil
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let color = NSColor.secondaryLabelColor.withAlphaComponent(0.4).cgColor
        ctx.setStrokeColor(color)
        ctx.setLineWidth(1)

        // Draw three diagonal lines (standard resize grip)
        let offsets: [CGFloat] = [3, 7, 11]
        for offset in offsets {
            ctx.move(to: CGPoint(x: bounds.maxX - offset, y: bounds.minY))
            ctx.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + offset))
            ctx.strokePath()
        }
    }
}
