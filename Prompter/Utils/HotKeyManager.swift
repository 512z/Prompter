import Carbon
import AppKit

class HotKeyManager {
    static let shared = HotKeyManager()

    private var eventHandler: EventHandlerRef?
    private var hotKeyId: EventHotKeyID?
    private var hotKeyRef: EventHotKeyRef?

    private init() {}

    func registerHotKey(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let action = Unmanaged<ActionWrapper>.fromOpaque(userData).takeUnretainedValue()
            action.perform()
            return noErr
        }

        let actionWrapper = ActionWrapper(action: action)
        let userDataPtr = Unmanaged.passRetained(actionWrapper).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, userDataPtr, &eventHandler)

        let hotKeyID = EventHotKeyID(signature: OSType(0x484B5459), id: 1) // 'HKTY'
        var hotKeyRefTemp: EventHotKeyRef?

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRefTemp)

        self.hotKeyId = hotKeyID
        self.hotKeyRef = hotKeyRefTemp
    }

    func unregisterHotKey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}

private class ActionWrapper {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    func perform() {
        action()
    }
}

// Common hotkey combinations
extension HotKeyManager {
    // Register Cmd+Shift+P as default hotkey
    func registerDefaultHotKey(action: @escaping () -> Void) {
        let keyCode: UInt32 = 35 // P key
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        registerHotKey(keyCode: keyCode, modifiers: modifiers, action: action)
    }
}
