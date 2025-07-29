import Cocoa
import SwiftTerm

class TerminalViewController: NSViewController {
    private var terminalView: LocalProcessTerminalView!
    private let shellPath = "/bin/zsh"
    
    override func loadView() {
        view = NSView()
        setupTerminal()
    }
    
    private func setupTerminal() {
        terminalView = LocalProcessTerminalView(frame: view.bounds)
        terminalView.autoresizingMask = [.width, .height]
        
        // Terminal Configuration
        terminalView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        terminalView.installColors(TerminalConfig.colorScheme)
        
        // Mouse support for text selection (copy/paste)
        terminalView.allowMouseReporting = false // Disable for now to avoid escape sequences
        
        // Terminal is already configured to accept first responder
        
        // Process starten
        let environment = ProcessInfo.processInfo.environment
        let envArray = environment.map { "\($0.key)=\($0.value)" }
        
        // Set working directory to user's preferred default directory
        let defaultDirectory = UserDefaults.standard.defaultDirectory
        FileManager.default.changeCurrentDirectoryPath(defaultDirectory)
        
        terminalView.startProcess(
            executable: shellPath,
            args: ["-l"], // Login shell
            environment: envArray,
            execName: shellPath
        )
        
        view.addSubview(terminalView)
    }
    
    func focus() {
        // Ensure terminal can accept input
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.window?.makeFirstResponder(self.terminalView)
            _ = self.terminalView.becomeFirstResponder()
            
            // Additional focus attempt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view.window?.makeKey()
                self.view.window?.makeFirstResponder(self.terminalView)
            }
        }
    }
    
    func handleKeyEvent(_ event: NSEvent) {
        terminalView.keyDown(with: event)
    }
    
    func paste() {
        guard let clipboard = NSPasteboard.general.string(forType: .string) else { return }
        terminalView.send(txt: clipboard)
    }
    
    func getTerminalView() -> LocalProcessTerminalView {
        return terminalView
    }
    
    func sendText(_ text: String) {
        terminalView.send(txt: text)
    }
    
    func copySelectedText() {
        // SwiftTerm should handle copy automatically with selection
        // For now, we'll let the terminal handle its own copy mechanism
        terminalView.copy(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        // Terminal läuft weiter im Hintergrund - keine Aktion nötig
    }
}