import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isDropdownVisible = false
    @Published var currentTabIndex = 0
    @Published var terminalSessions: [TerminalSession] = []
    
    private init() {}
    
    func addTerminalSession() -> TerminalSession {
        let session = TerminalSession(id: UUID(), title: "Terminal \(terminalSessions.count + 1)")
        terminalSessions.append(session)
        return session
    }
    
    func removeTerminalSession(at index: Int) {
        guard index < terminalSessions.count else { return }
        terminalSessions.remove(at: index)
        
        if currentTabIndex >= terminalSessions.count {
            currentTabIndex = max(0, terminalSessions.count - 1)
        }
    }
}

struct TerminalSession: Identifiable {
    let id: UUID
    var title: String
    var isActive: Bool = false
}