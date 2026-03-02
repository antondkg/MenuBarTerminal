import Cocoa
import SwiftTerm

class TerminalTabView: NSView, TerminalViewControllerDelegate {
    private let headerView = NSVisualEffectView()
    private let tabBar = NSSegmentedControl()
    private let newTabButton = NSButton()
    private let closeTabButton = NSButton()
    private let containerView = NSView()
    private var terminals: [TerminalViewController] = []
    private var currentIndex = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        createInitialTab()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        // Header setup
        headerView.material = .headerView
        headerView.blendingMode = .withinWindow
        headerView.state = .active
        headerView.wantsLayer = true
        headerView.layer?.cornerRadius = 10
        headerView.layer?.masksToBounds = true
        headerView.translatesAutoresizingMaskIntoConstraints = false

        // Tab bar setup
        tabBar.segmentStyle = .rounded
        tabBar.controlSize = .small
        tabBar.trackingMode = .selectOne
        tabBar.target = self
        tabBar.action = #selector(tabChanged(_:))
        tabBar.translatesAutoresizingMaskIntoConstraints = false

        // New tab button
        newTabButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "New Tab")
        newTabButton.bezelStyle = .texturedRounded
        newTabButton.isBordered = true
        newTabButton.controlSize = .small
        newTabButton.target = self
        newTabButton.action = #selector(createNewTab)
        newTabButton.translatesAutoresizingMaskIntoConstraints = false

        // Close tab button
        closeTabButton.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close Tab")
        closeTabButton.bezelStyle = .texturedRounded
        closeTabButton.isBordered = true
        closeTabButton.controlSize = .small
        closeTabButton.target = self
        closeTabButton.action = #selector(closeCurrentTab)
        closeTabButton.translatesAutoresizingMaskIntoConstraints = false

        // Terminal container
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 10
        containerView.layer?.masksToBounds = true
        containerView.layer?.borderWidth = 1
        containerView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        containerView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        // Layout
        addSubview(headerView)
        headerView.addSubview(tabBar)
        headerView.addSubview(newTabButton)
        headerView.addSubview(closeTabButton)
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            headerView.heightAnchor.constraint(equalToConstant: 34),

            tabBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            tabBar.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            tabBar.trailingAnchor.constraint(lessThanOrEqualTo: newTabButton.leadingAnchor, constant: -8),
            tabBar.heightAnchor.constraint(equalToConstant: 24),

            closeTabButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            closeTabButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeTabButton.widthAnchor.constraint(equalToConstant: 24),
            closeTabButton.heightAnchor.constraint(equalToConstant: 24),

            newTabButton.trailingAnchor.constraint(equalTo: closeTabButton.leadingAnchor, constant: -6),
            newTabButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            newTabButton.widthAnchor.constraint(equalToConstant: 24),
            newTabButton.heightAnchor.constraint(equalToConstant: 24),

            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // New Tab Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(createNewTab),
            name: .newTerminalTab,
            object: nil
        )
    }
    
    private func createInitialTab() {
        createNewTab()
    }
    
    @objc private func createNewTab() {
        let terminal = TerminalViewController()
        terminal.delegate = self
        terminals.append(terminal)
        
        updateTabBar()
        tabBar.selectedSegment = terminals.count - 1
        showTerminal(at: terminals.count - 1)
    }
    
    private func updateTabBar() {
        tabBar.segmentCount = terminals.count
        
        for i in 0..<terminals.count {
            let title = titleForTerminal(at: i)
            tabBar.setLabel(title, forSegment: i)
            tabBar.setWidth(130, forSegment: i)
        }

        closeTabButton.isEnabled = terminals.count > 1
    }
    
    private func closeTab(at index: Int) {
        guard index < terminals.count, terminals.count > 1 else { return }
        
        terminals.remove(at: index)
        
        // Update current index if needed
        if currentIndex >= terminals.count {
            currentIndex = terminals.count - 1
        } else if currentIndex > index {
            currentIndex -= 1
        }
        
        updateTabBar()
        tabBar.selectedSegment = currentIndex
        showTerminal(at: currentIndex)
    }
    
    @objc private func closeCurrentTab() {
        closeTab(at: currentIndex)
    }

    @objc private func tabChanged(_ sender: NSSegmentedControl) {
        let index = sender.selectedSegment

        showTerminal(at: index)
    }
    
    private func showTerminal(at index: Int) {
        guard index < terminals.count else { return }
        
        // Remove current
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new
        let terminal = terminals[index]
        containerView.addSubview(terminal.view)
        terminal.view.frame = containerView.bounds
        terminal.view.autoresizingMask = [.width, .height]
        
        currentIndex = index
        tabBar.selectedSegment = index
        for (i, item) in terminals.enumerated() {
            item.setFocusIndicator(i == index)
        }
        updateTabBar()
    }

    private func titleForTerminal(at index: Int) -> String {
        guard index < terminals.count else { return "Terminal \(index + 1)" }
        let terminal = terminals[index]
        let preferred = !terminal.currentDirectoryLabel.isEmpty ? terminal.currentDirectoryLabel : terminal.currentTitle
        let shortened = compactTitle(preferred)
        return "\(index + 1) \(shortened)"
    }

    private func compactTitle(_ value: String) -> String {
        if value.count <= 18 { return value }
        let prefix = value.prefix(17)
        return "\(prefix)…"
    }

    func terminalTitleChanged(_ controller: TerminalViewController, title: String) {
        updateTabBar()
    }
    
    func focusCurrentTerminal() {
        guard currentIndex < terminals.count else { return }
        terminals[currentIndex].focus()
    }
    
    func handleKeyEvent(_ event: NSEvent) {
        guard currentIndex < terminals.count else { return }
        terminals[currentIndex].handleKeyEvent(event)
    }
    
    func pasteToCurrentTerminal() {
        guard currentIndex < terminals.count else { return }
        terminals[currentIndex].paste()
    }
    
    func getCurrentTerminalView() -> LocalProcessTerminalView? {
        guard currentIndex < terminals.count else { return nil }
        return terminals[currentIndex].getTerminalView()
    }
    
    func sendTextToCurrentTerminal(_ text: String) {
        guard currentIndex < terminals.count else { return }
        terminals[currentIndex].sendText(text)
    }
    
    func copyFromCurrentTerminal() {
        guard currentIndex < terminals.count else { return }
        terminals[currentIndex].copySelectedText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
