import Cocoa
import Carbon

extension AppDelegate {
    func setupKeyboardShortcuts() {
        // Global Hotkey: Cmd+Shift+T using Carbon API
        let hotKeyID = EventHotKeyID(signature: OSType(0x54657374), id: 1)
        var hotKeyRef: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_T),
            UInt32(cmdKey + shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register global hotkey: \(status)")
        }
        
        // Install event handler
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventSpec, Unmanaged.passUnretained(self).toOpaque(), nil)
    }
}

private let hotKeyHandler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
    guard let userData = userData else { return OSStatus(eventNotHandledErr) }
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
    
    var hotKeyID = EventHotKeyID()
    GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
    
    if hotKeyID.id == 1 {
        DispatchQueue.main.async {
            appDelegate.toggleDropdown()
        }
    }
    
    return OSStatus(noErr)
}