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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "Prompter")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Configure popover
        popover.contentSize = NSSize(width: 360, height: 500)
        popover.behavior = .transient
        popover.animates = true

        // Create hosting controller with transparent background
        let hostingController = NSHostingController(rootView: MenuBarPopover())
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        popover.contentViewController = hostingController

        // Make popover background translucent
        popover.appearance = NSAppearance(named: .vibrantLight)

        // Register global hotkey (Cmd+Shift+P)
        HotKeyManager.shared.registerDefaultHotKey { [weak self] in
            self?.togglePopover()
        }
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

                // Make popover background translucent
                DispatchQueue.main.async { [weak self] in
                    if let popoverWindow = self?.popover.contentViewController?.view.window {
                        popoverWindow.backgroundColor = .clear
                        popoverWindow.isOpaque = false

                        // Find and configure the background view
                        if let backgroundView = popoverWindow.contentView?.superview {
                            let visualEffect = NSVisualEffectView()
                            visualEffect.material = .hudWindow
                            visualEffect.blendingMode = .behindWindow
                            visualEffect.state = .active
                            visualEffect.frame = backgroundView.bounds
                            visualEffect.autoresizingMask = [.width, .height]
                            backgroundView.addSubview(visualEffect, positioned: .below, relativeTo: nil)
                        }
                    }
                }
            }
        }
    }
}
