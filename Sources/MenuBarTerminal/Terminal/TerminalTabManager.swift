import Foundation
import SwiftTerm

class TerminalTabManager: ObservableObject {
    @Published var tabs: [TerminalTab] = []
    @Published var activeTabIndex: Int = 0
    
    init() {
        createNewTab()
    }
    
    func createNewTab() {
        let tab = TerminalTab(
            id: UUID(),
            title: "Terminal \(tabs.count + 1)",
            controller: TerminalViewController()
        )
        tabs.append(tab)
        activeTabIndex = tabs.count - 1
    }
    
    func closeTab(at index: Int) {
        guard index < tabs.count, tabs.count > 1 else { return }
        
        tabs.remove(at: index)
        
        if activeTabIndex >= tabs.count {
            activeTabIndex = tabs.count - 1
        } else if activeTabIndex > index {
            activeTabIndex -= 1
        }
    }
    
    func selectTab(at index: Int) {
        guard index < tabs.count else { return }
        activeTabIndex = index
    }
    
    var activeTab: TerminalTab? {
        guard activeTabIndex < tabs.count else { return nil }
        return tabs[activeTabIndex]
    }
}

struct TerminalTab: Identifiable {
    let id: UUID
    var title: String
    let controller: TerminalViewController
}