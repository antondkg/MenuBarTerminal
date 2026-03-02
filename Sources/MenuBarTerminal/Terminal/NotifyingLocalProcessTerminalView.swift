import Foundation
import SwiftTerm

final class NotifyingLocalProcessTerminalView: LocalProcessTerminalView {
    var onBell: (() -> Void)?
    var onActivityCompleted: (() -> Void)?
    var activityCompletionIdleDelay: TimeInterval = 1.3

    private let genericCompletionOutputThreshold = 64
    private let aiCliCompletionOutputThreshold = 8
    private var pendingActivityCompletion = false
    private var outputBytesSinceSubmit = 0
    private var printableCharsSinceSubmit = 0
    private var aiCliSessionActive = false
    private var sawAiCliBusyMarkerForPending = false
    private var recentOutputWindow = ""
    private var completionTimer: DispatchWorkItem?

    override func send(source: TerminalView, data: ArraySlice<UInt8>) {
        super.send(source: source, data: data)
        refreshSessionState()

        guard data.contains(10) || data.contains(13) else { return }
        pendingActivityCompletion = true
        outputBytesSinceSubmit = 0
        printableCharsSinceSubmit = 0
        sawAiCliBusyMarkerForPending = false
        completionTimer?.cancel()
    }

    override func bell(source: Terminal) {
        super.bell(source: source)
        onBell?()
    }

    override func dataReceived(slice: ArraySlice<UInt8>) {
        super.dataReceived(slice: slice)
        refreshSessionState()
        inspectOutputMarkers(slice)

        guard pendingActivityCompletion else { return }
        outputBytesSinceSubmit += slice.count
        printableCharsSinceSubmit += countPrintableCharacters(in: slice)
        scheduleCompletionTimer()
    }

    override func processTerminated(_ source: LocalProcess, exitCode: Int32?) {
        super.processTerminated(source, exitCode: exitCode)
        completionTimer?.cancel()
        completionTimer = nil
        pendingActivityCompletion = false
        outputBytesSinceSubmit = 0
        printableCharsSinceSubmit = 0
        aiCliSessionActive = false
        sawAiCliBusyMarkerForPending = false
        recentOutputWindow = ""
    }

    private func scheduleCompletionTimer() {
        completionTimer?.cancel()

        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard self.pendingActivityCompletion else { return }

            // Keep normal shell behavior strict, but allow short AI CLI turns.
            let genericReady = self.outputBytesSinceSubmit >= self.genericCompletionOutputThreshold
            let aiCliReady = self.aiCliSessionActive
                && self.outputBytesSinceSubmit >= self.aiCliCompletionOutputThreshold
                && self.printableCharsSinceSubmit > 0
            let aiCliBusyReady = self.aiCliSessionActive
                && self.sawAiCliBusyMarkerForPending
                && self.printableCharsSinceSubmit > 0
            if genericReady || aiCliReady || aiCliBusyReady {
                self.onActivityCompleted?()
            }

            self.pendingActivityCompletion = false
            self.outputBytesSinceSubmit = 0
            self.printableCharsSinceSubmit = 0
            self.sawAiCliBusyMarkerForPending = false
            self.completionTimer = nil
        }

        completionTimer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + activityCompletionIdleDelay, execute: work)
    }

    private func inspectOutputMarkers(_ slice: ArraySlice<UInt8>) {
        guard !slice.isEmpty else { return }
        let chunk = String(decoding: slice, as: UTF8.self).lowercased()
        guard !chunk.isEmpty else { return }

        recentOutputWindow += chunk
        if recentOutputWindow.count > 4096 {
            recentOutputWindow = String(recentOutputWindow.suffix(4096))
        }

        if recentOutputWindow.contains("openai codex")
            || recentOutputWindow.contains("codex (v")
            || (recentOutputWindow.contains("gpt-") && recentOutputWindow.contains("codex"))
            || recentOutputWindow.contains("claude code")
            || recentOutputWindow.contains("opencode")
            || recentOutputWindow.contains("open code") {
            aiCliSessionActive = true
        }

        if recentOutputWindow.contains("esc to interrupt") {
            aiCliSessionActive = true
            if pendingActivityCompletion {
                sawAiCliBusyMarkerForPending = true
            }
        }
    }

    private func countPrintableCharacters(in slice: ArraySlice<UInt8>) -> Int {
        let text = String(decoding: slice, as: UTF8.self)
        return text.unicodeScalars.reduce(into: 0) { count, scalar in
            // Ignore control characters and DEL.
            let value = scalar.value
            if value >= 32 && value != 127 {
                count += 1
            }
        }
    }
}
