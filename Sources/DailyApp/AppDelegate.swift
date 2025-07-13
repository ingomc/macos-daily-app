import Cocoa
import SwiftUI
import HotKey

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    var hotKey: HotKey!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App nicht im Dock anzeigen
        NSApp.setActivationPolicy(.accessory)
        
        // Status Bar Item erstellen
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let statusButton = statusBarItem.button {
            statusButton.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Daily Tasks")
            
            // Links-Klick für Toggle, Rechts-Klick für Menü
            statusButton.action = #selector(statusBarButtonClicked(_:))
            statusButton.target = self
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Popover konfigurieren
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        // Event Monitor für Klicks außerhalb des Popovers
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        // Globales Tastenkürzel registrieren (Cmd+Shift+D)
        setupGlobalHotkey()
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // Rechtsklick - Menü anzeigen
            showContextMenu()
        } else {
            // Linksklick - Popover togglen
            togglePopover()
        }
    }
    
    func showContextMenu() {
        let menu = NSMenu()
        
        let openItem = NSMenuItem(title: "Aufgaben öffnen", action: #selector(showPopoverFromMenu), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "Über Daily App", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: "Beenden", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // Modernes Menu-Handling für macOS 14+
        statusBarItem.menu = menu
        statusBarItem.button?.performClick(nil)
        
        // Menu nach kurzer Zeit wieder entfernen, damit Links-Klick wieder funktioniert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusBarItem.menu = nil
        }
    }
    
    @objc func showPopoverFromMenu() {
        showPopover(sender: nil)
    }

    @objc func togglePopover() {
        if popover.isShown {
            closePopover(sender: nil)
        } else {
            showPopover(sender: nil)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    @objc func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func setupGlobalHotkey() {
        // Globales Tastenkürzel: Cmd+Shift+D
        hotKey = HotKey(key: .d, modifiers: [.command, .shift])
        hotKey.keyDownHandler = { [weak self] in
            self?.togglePopover()
        }
        print("Globales Tastenkürzel registriert: Cmd+Shift+D")
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Daily App"
        alert.informativeText = """
        Version 1.0
        
        Eine einfache App zum Tracken deiner täglichen Aufgaben.
        
        Tastenkürzel: Cmd+Shift+D
        
        Entwickelt mit Swift & SwiftUI für macOS
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
