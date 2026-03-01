import Cocoa
import SwiftTerm

// ---------------------------------------------------------------------------
//  ScrollWheelSwizzle
//
//  Swizzle SwiftTerm's TerminalView.scrollWheel(with:) at the ObjC runtime
//  level so we can intercept trackpad / mouse-wheel events and translate them
//  to input for TUI apps running in the alternate screen buffer.
//
//  SwiftTerm's built-in scrollWheel only manipulates the scrollback buffer
//  (yDisp), it never sends data to the child process.  TUI apps (vim, less,
//  claude, opencode, ...) switch to the alternate buffer where there IS no
//  scrollback -- they expect scroll events as either:
//    * mouse scroll-button press/release (when mouse reporting is on), or
//    * arrow-key / page-key escape sequences (when mouse reporting is off).
//
//  We can't subclass TerminalView.scrollWheel because it is `public` but not
//  `open`.  Swizzling at the ObjC runtime level avoids that restriction.
// ---------------------------------------------------------------------------

private var scrollAccumulator: CGFloat = 0

/// Call once (e.g. in applicationDidFinishLaunching) to install the swizzle.
func installScrollWheelSwizzle() {
    let cls: AnyClass = TerminalView.self

    let originalSel = #selector(NSView.scrollWheel(with:))
    let swizzledSel = #selector(TerminalView.mbt_scrollWheel(with:))

    guard let originalMethod = class_getInstanceMethod(cls, originalSel),
          let swizzledMethod = class_getInstanceMethod(cls, swizzledSel) else {
        scrollLog("installScrollWheelSwizzle: FAILED to find methods")
        return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
    scrollLog("installScrollWheelSwizzle: swizzle installed successfully")
}

// ---------------------------------------------------------------------------
//  The replacement implementation, added as a category method on TerminalView.
// ---------------------------------------------------------------------------

extension TerminalView {

    /// After swizzling, calling `self.mbt_scrollWheel(with:)` actually invokes
    /// the **original** SwiftTerm implementation (the selectors are swapped).
    @objc func mbt_scrollWheel(with event: NSEvent) {

        let terminal = self.getTerminal()

        if terminal.isCurrentBufferAlternate {
            // We are in a TUI app's alternate buffer.  Translate scroll
            // events into terminal input instead of manipulating yDisp.

            let rawDelta: CGFloat
            if event.hasPreciseScrollingDeltas {
                rawDelta = event.scrollingDeltaY       // trackpad: pixel delta
            } else {
                rawDelta = event.deltaY * 10           // mouse wheel: line delta
            }

            scrollLog("mbt_scrollWheel: altBuffer rawDelta=\(rawDelta) accum=\(scrollAccumulator) mouseMode=\(terminal.mouseMode) appCursor=\(terminal.applicationCursor) phase=\(event.phase.rawValue) momentumPhase=\(event.momentumPhase.rawValue)")

            // Reset accumulator at start of a new gesture
            if event.phase == .began {
                scrollAccumulator = 0
            }

            guard rawDelta != 0 else { return }

            scrollAccumulator += rawDelta
            let lineThreshold: CGFloat = 10.0

            while abs(scrollAccumulator) >= lineThreshold {
                let goingUp = scrollAccumulator > 0

                if terminal.mouseMode != .off {
                    // TUI is using mouse reporting.
                    // Button 64 = scroll up, 65 = scroll down (X10 encoding).
                    let btn = goingUp ? 64 : 65
                    terminal.sendEvent(buttonFlags: btn, x: 0, y: 0)
                    scrollLog("  -> mouse button \(btn)")
                } else {
                    // No mouse reporting -- send arrow key escape sequences
                    // exactly like SwiftTerm's own sendKeyUp / sendKeyDown.
                    if terminal.applicationCursor {
                        self.send(goingUp
                                  ? EscapeSequences.moveUpApp
                                  : EscapeSequences.moveDownApp)
                    } else {
                        self.send(goingUp
                                  ? EscapeSequences.moveUpNormal
                                  : EscapeSequences.moveDownNormal)
                    }
                    scrollLog("  -> arrow key (appCursor=\(terminal.applicationCursor) up=\(goingUp))")
                }

                scrollAccumulator -= goingUp ? lineThreshold : -lineThreshold
            }

            // Reset accumulator at gesture boundaries
            if event.phase == .ended || event.phase == .cancelled
                || event.momentumPhase == .ended {
                scrollAccumulator = 0
            }

            return   // event consumed -- do NOT fall through to original impl
        }

        // Normal buffer -- delegate to the original SwiftTerm scrollWheel.
        // Because the selectors are swapped, calling mbt_scrollWheel
        // here actually calls the ORIGINAL implementation.
        self.mbt_scrollWheel(with: event)
    }
}

// ---------------------------------------------------------------------------
//  Debug logger (shared with DropdownWindow -- same file path)
// ---------------------------------------------------------------------------
func scrollLog(_ message: String) {
    let ts = ISO8601DateFormatter().string(from: Date())
    let line = "[\(ts)] \(message)\n"
    let path = "/tmp/menubar_scroll_debug.log"
    if let fh = FileHandle(forWritingAtPath: path) {
        fh.seekToEndOfFile()
        fh.write(line.data(using: .utf8)!)
        fh.closeFile()
    } else {
        FileManager.default.createFile(atPath: path, contents: line.data(using: .utf8))
    }
}
