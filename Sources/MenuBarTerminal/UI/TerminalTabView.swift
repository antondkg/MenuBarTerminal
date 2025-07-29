import Cocoa
import SwiftTerm

class TerminalTabView: NSView {
    private let tabBar = NSSegmentedControl()
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
        // Tab Bar Setup
        tabBar.segmentStyle = .texturedRounded
        tabBar.target = self
        tabBar.action = #selector(tabChanged(_:))
        
        // Layout
        addSubview(tabBar)
        addSubview(containerView)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tabBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tabBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            tabBar.heightAnchor.constraint(equalToConstant: 28),
            
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
        terminals.append(terminal)
        
        // Update Tab Bar with close buttons
        updateTabBar()
        tabBar.selectedSegment = terminals.count - 1
        
        // Show new terminal
        showTerminal(at: terminals.count - 1)
    }
    
    private func updateTabBar() {
        tabBar.segmentCount = terminals.count
        
        for i in 0..<terminals.count {
            let title = terminals.count > 1 ? "Terminal \(i + 1) ✕" : "Terminal \(i + 1)"
            tabBar.setLabel(title, forSegment: i)
        }
        
        // Always show tab bar, even with single tab
        tabBar.isHidden = false
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
    
    @objc private func tabChanged(_ sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        
        // Check if user clicked on close button (✕)
        if terminals.count > 1, let title = sender.label(forSegment: index), title.contains("✕") {
            // Get click location to determine if close button was clicked
            if let event = NSApp.currentEvent, event.type == .leftMouseUp {
                let segmentFrame = sender.frame
                let clickX = event.locationInWindow.x - segmentFrame.minX
                let segmentWidth = segmentFrame.width / CGFloat(sender.segmentCount)
                let relativeX = clickX - (CGFloat(index) * segmentWidth)
                
                // If clicked on right side of segment (where ✕ is), close tab
                if relativeX > segmentWidth * 0.7 {
                    closeTab(at: index)
                    return
                }
            }
        }
        
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