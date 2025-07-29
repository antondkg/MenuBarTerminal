import Cocoa

struct AnimationHelper {
    static let defaultDuration: TimeInterval = 0.25
    static let fastDuration: TimeInterval = 0.15
    static let slowDuration: TimeInterval = 0.4
    
    static func slideDown(window: NSWindow, to finalFrame: NSRect, completion: (() -> Void)? = nil) {
        let startFrame = NSRect(
            x: finalFrame.minX,
            y: finalFrame.maxY,
            width: finalFrame.width,
            height: 0
        )
        
        window.setFrame(startFrame, display: false)
        window.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = defaultDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(finalFrame, display: true)
            window.animator().alphaValue = 1.0
        }, completionHandler: completion)
    }
    
    static func slideUp(window: NSWindow, completion: (() -> Void)? = nil) {
        let startFrame = window.frame
        let finalFrame = NSRect(
            x: startFrame.minX,
            y: startFrame.maxY,
            width: startFrame.width,
            height: 0
        )
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = defaultDuration * 0.8
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(finalFrame, display: true)
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            window.orderOut(nil)
            completion?()
        })
    }
    
    static func fadeIn(view: NSView, duration: TimeInterval = defaultDuration, completion: (() -> Void)? = nil) {
        view.alphaValue = 0.0
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            view.animator().alphaValue = 1.0
        }, completionHandler: completion)
    }
    
    static func fadeOut(view: NSView, duration: TimeInterval = defaultDuration, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            view.animator().alphaValue = 0.0
        }, completionHandler: completion)
    }
}