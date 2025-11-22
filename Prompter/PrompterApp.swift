import SwiftUI
import UserNotifications

@main
struct PrompterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var customWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use simple SF Symbol for menu bar
            if let image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "Prompter") {
                image.isTemplate = true // Makes it monochrome white
                button.image = image
            }

            button.action = #selector(togglePopover)
            button.target = self
        }

        // Configure popover
        popover.contentSize = NSSize(width: 360, height: 500)
        popover.behavior = .transient
        popover.animates = true

        // Enable full customization on macOS 14+
        if #available(macOS 14.0, *) {
            popover.hasFullSizeContent = true
        }

        // Create hosting controller with transparent background
        let hostingController = NSHostingController(rootView: MenuBarPopover())
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        popover.contentViewController = hostingController

        // Register global hotkey (Cmd+Shift+P)
        HotKeyManager.shared.registerDefaultHotKey { [weak self] in
            self?.togglePopover()
        }
    }

    @objc func togglePopover() {
        if customWindow?.isVisible == true {
            closeCustomWindow()
        } else {
            showCustomWindow()
        }
    }

    func showCustomWindow() {
        guard let button = statusItem?.button else { return }

        // Create custom window if needed
        if customWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 360, height: 500),
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = true
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]

            // Create visual effect view with rounded corners
            let visualEffect = NSVisualEffectView(frame: window.contentView!.bounds)
            visualEffect.material = .hudWindow
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active
            visualEffect.autoresizingMask = [.width, .height]
            visualEffect.wantsLayer = true
            visualEffect.layer?.cornerRadius = 12
            visualEffect.layer?.masksToBounds = true

            // Add SwiftUI content
            let hostingView = NSHostingController(rootView: MenuBarPopover())
            hostingView.view.frame = window.contentView!.bounds
            hostingView.view.autoresizingMask = [.width, .height]
            hostingView.view.wantsLayer = true
            hostingView.view.layer?.backgroundColor = .clear

            window.contentView?.addSubview(visualEffect)
            window.contentView?.addSubview(hostingView.view)

            customWindow = window
        }

        // Position window below menu bar button
        if let window = customWindow {
            let buttonFrame = button.window!.convertToScreen(button.convert(button.bounds, to: nil))
            let windowX = buttonFrame.midX - window.frame.width / 2
            let windowY = buttonFrame.minY - window.frame.height - 8

            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
            window.makeKeyAndOrderFront(nil)

            // Monitor clicks outside
            NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.closeCustomWindow()
            }
        }
    }

    func closeCustomWindow() {
        customWindow?.orderOut(nil)
    }
}
