import XCTest
@testable import MenuBarTerminal

final class MenuBarTerminalTests: XCTestCase {
    
    func testAppStateInitialization() {
        let appState = AppState.shared
        XCTAssertFalse(appState.isDropdownVisible)
        XCTAssertEqual(appState.currentTabIndex, 0)
        XCTAssertTrue(appState.terminalSessions.isEmpty)
    }
    
    func testTerminalSessionCreation() {
        let appState = AppState.shared
        let session = appState.addTerminalSession()
        
        XCTAssertEqual(appState.terminalSessions.count, 1)
        XCTAssertEqual(session.title, "Terminal 1")
        XCTAssertFalse(session.isActive)
    }
    
    func testUserDefaultsExtension() {
        let defaults = UserDefaults.standard
        
        // Test default values
        XCTAssertEqual(defaults.windowWidth, 800)
        XCTAssertEqual(defaults.windowHeight, 500)
        XCTAssertEqual(defaults.fontSize, 13)
        XCTAssertEqual(defaults.colorScheme, "default")
        XCTAssertFalse(defaults.autoHide)
        XCTAssertFalse(defaults.globalHotkeyEnabled)
    }
    
    func testTerminalConfig() {
        XCTAssertEqual(TerminalConfig.colorScheme.count, 16)
        XCTAssertNotNil(TerminalConfig.defaultFont)
    }
}