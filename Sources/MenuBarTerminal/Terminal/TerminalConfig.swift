import SwiftTerm
import Cocoa

struct TerminalConfig {
    static let colorScheme: [Color] = [
        // ANSI Colors (0-15)
        Color(red: 0, green: 0, blue: 0),         // Black
        Color(red: 52428, green: 0, blue: 0),     // Red
        Color(red: 0, green: 52428, blue: 0),     // Green
        Color(red: 52428, green: 52428, blue: 0), // Yellow
        Color(red: 0, green: 0, blue: 52428),     // Blue
        Color(red: 52428, green: 0, blue: 52428), // Magenta
        Color(red: 0, green: 52428, blue: 52428), // Cyan
        Color(red: 52428, green: 52428, blue: 52428), // White
        // Bright colors (8-15)
        Color(red: 26214, green: 26214, blue: 26214), // Bright Black
        Color(red: 65535, green: 0, blue: 0),         // Bright Red
        Color(red: 0, green: 65535, blue: 0),         // Bright Green
        Color(red: 65535, green: 65535, blue: 0),     // Bright Yellow
        Color(red: 0, green: 0, blue: 65535),         // Bright Blue
        Color(red: 65535, green: 0, blue: 65535),     // Bright Magenta
        Color(red: 0, green: 65535, blue: 65535),     // Bright Cyan
        Color(red: 65535, green: 65535, blue: 65535), // Bright White
    ]
    
    static var defaultFont: NSFont {
        return NSFont(name: "MesloLGS NF", size: 13) ?? NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    }
}