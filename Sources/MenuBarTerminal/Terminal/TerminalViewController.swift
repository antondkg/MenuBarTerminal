import Cocoa
import SwiftTerm

protocol TerminalViewControllerDelegate: AnyObject {
    func terminalTitleChanged(_ controller: TerminalViewController, title: String)
}

/// Wrapper view that ensures scroll and mouse events work in borderless windows
class TerminalContainerView: NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

class TerminalViewController: NSViewController, LocalProcessTerminalViewDelegate {
    private var terminalView: LocalProcessTerminalView!
    private let shellPath = "/bin/zsh"
    weak var delegate: TerminalViewControllerDelegate?
    private(set) var currentTitle: String = "Terminal"
    private(set) var currentDirectoryLabel: String = ""
    private var currentDirectory: String = ""
    private var focusBorder: NSView?

    override func loadView() {
        let container = TerminalContainerView()
        container.wantsLayer = true
        container.layer?.masksToBounds = true
        view = container
        setupTerminal()
        setupFocusBorder()
    }

    private func setupTerminal() {
        terminalView = LocalProcessTerminalView(frame: view.bounds)
        terminalView.autoresizingMask = [.width, .height]
        terminalView.processDelegate = self

        terminalView.font = TerminalConfig.defaultFont
        terminalView.installColors(TerminalConfig.colorScheme)
        // Use font-provided box drawing glyphs for tmux pane separators.
        // SwiftTerm's custom renderer can overpaint neighboring cells in split panes.
        terminalView.customBlockGlyphs = false

        var environment = ProcessInfo.processInfo.environment
        environment["TERM"] = "xterm-256color"
        environment["COLORTERM"] = "truecolor"
        environment["TERM_PROGRAM"] = "MenuBarTerminal"
        environment["LANG"] = environment["LANG"] ?? "en_US.UTF-8"
        let envArray = environment.map { "\($0.key)=\($0.value)" }

        let defaultDirectory = UserDefaults.standard.defaultDirectory
        FileManager.default.changeCurrentDirectoryPath(defaultDirectory)

        terminalView.startProcess(
            executable: shellPath,
            args: ["-l"],
            environment: envArray,
            execName: shellPath
        )

        view.addSubview(terminalView)
        updateDirectoryLabel(directory: defaultDirectory)
    }

    private func updateDirectoryLabel(directory: String? = nil) {
        if let dir = directory {
            currentDirectory = dir
        }

        if currentDirectory.isEmpty {
            currentDirectoryLabel = ""
        } else {
            let home = NSHomeDirectory()
            if currentDirectory == home {
                currentDirectoryLabel = "~"
            } else if currentDirectory.hasPrefix(home + "/") {
                let relative = String(currentDirectory.dropFirst(home.count + 1))
                currentDirectoryLabel = "~/" + relative
            } else {
                currentDirectoryLabel = (currentDirectory as NSString).lastPathComponent
            }
        }

        delegate?.terminalTitleChanged(self, title: currentTitle)
    }

    // MARK: - LocalProcessTerminalViewDelegate

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        currentTitle = title.isEmpty ? "Terminal" : title
        delegate?.terminalTitleChanged(self, title: currentTitle)
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        if let dir = directory {
            if let url = URL(string: dir) {
                updateDirectoryLabel(directory: url.path)
            } else {
                updateDirectoryLabel(directory: dir)
            }
        }
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {}

    func focus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.window?.makeFirstResponder(self.terminalView)
            _ = self.terminalView.becomeFirstResponder()

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
        terminalView.copy(self)
    }

    // MARK: - Focus Indicator

    private func setupFocusBorder() {
        let border = NSView()
        border.wantsLayer = true
        border.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        border.isHidden = true
        view.addSubview(border)

        border.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: view.topAnchor),
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 2),
        ])
        focusBorder = border
    }

    func setFocusIndicator(_ show: Bool) {
        focusBorder?.isHidden = !show
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
}
