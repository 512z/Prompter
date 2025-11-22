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
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

                // Add glassmorphism effect to popover background
                DispatchQueue.main.async { [weak self] in
                    guard let window = self?.popover.contentViewController?.view.window,
                          let frameView = window.contentView?.superview else { return }

                    // Make window transparent
                    window.backgroundColor = .clear
                    window.isOpaque = false

                    // Add visual effect view to frameView (popover's background)
                    let visualEffect = NSVisualEffectView(frame: frameView.bounds)
                    visualEffect.material = .hudWindow
                    visualEffect.blendingMode = .behindWindow
                    visualEffect.state = .active
                    visualEffect.autoresizingMask = [.width, .height]
                    visualEffect.wantsLayer = true

                    // Insert behind everything
                    frameView.addSubview(visualEffect, positioned: .below, relativeTo: frameView)
                }
            }
        }
    }
}
