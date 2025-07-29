import Foundation

extension UserDefaults {
    
    enum Keys {
        static let windowWidth = "windowWidth"
        static let windowHeight = "windowHeight"
        static let fontSize = "fontSize"
        static let colorScheme = "colorScheme"
        static let autoHide = "autoHide"
        static let globalHotkey = "globalHotkey"
    }
    
    // Window Settings
    var windowWidth: CGFloat {
        get { CGFloat(double(forKey: Keys.windowWidth) != 0 ? double(forKey: Keys.windowWidth) : 800) }
        set { set(Double(newValue), forKey: Keys.windowWidth) }
    }
    
    var windowHeight: CGFloat {
        get { CGFloat(double(forKey: Keys.windowHeight) != 0 ? double(forKey: Keys.windowHeight) : 500) }
        set { set(Double(newValue), forKey: Keys.windowHeight) }
    }
    
    // Terminal Settings
    var fontSize: CGFloat {
        get { CGFloat(double(forKey: Keys.fontSize) != 0 ? double(forKey: Keys.fontSize) : 13) }
        set { set(Double(newValue), forKey: Keys.fontSize) }
    }
    
    var colorScheme: String {
        get { string(forKey: Keys.colorScheme) ?? "default" }
        set { set(newValue, forKey: Keys.colorScheme) }
    }
    
    // Behavior Settings
    var autoHide: Bool {
        get { bool(forKey: Keys.autoHide) }
        set { set(newValue, forKey: Keys.autoHide) }
    }
    
    var globalHotkeyEnabled: Bool {
        get { bool(forKey: Keys.globalHotkey) }
        set { set(newValue, forKey: Keys.globalHotkey) }
    }
    
    // Autostart Settings
    var autostartEnabled: Bool {
        get { bool(forKey: "autostartEnabled") }
        set { set(newValue, forKey: "autostartEnabled") }
    }
    
    // Default Directory Settings
    var defaultDirectory: String {
        get { string(forKey: "defaultDirectory") ?? FileManager.default.homeDirectoryForCurrentUser.path }
        set { set(newValue, forKey: "defaultDirectory") }
    }
}