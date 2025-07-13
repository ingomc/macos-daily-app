import Cocoa
import SwiftUI
import HotKey

// ContentView direkt hier definieren für bessere Kompatibilität
struct AppContentView: View {
    @StateObject private var taskManager = AppTaskManager()
    @State private var newTaskText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var hoveredTask: UUID? = nil
    
    var body: some View {
        ZStack {
            // Liquid Glass Hintergrund für macOS 15+
            if #available(macOS 15.0, *) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.blue.opacity(0.05),
                                Color.purple.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
            } else {
                // Fallback für ältere Versionen
                Rectangle()
                    .fill(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
            }
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    if #available(macOS 15.0, *) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Daily Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(currentDateString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            if #available(macOS 15.0, *) {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                                    }
                            } else {
                                Capsule()
                                    .fill(Color(.controlBackgroundColor))
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Eingabefeld
                HStack(spacing: 12) {
                    if #available(macOS 15.0, *) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .symbolEffect(.bounce, value: newTaskText.isEmpty)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    
                    TextField("Was hast du heute gemacht?", text: $newTaskText)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            addTask()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background {
                            if #available(macOS 15.0, *) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: isTextFieldFocused ? 
                                                        [.blue.opacity(0.5), .purple.opacity(0.3)] : 
                                                        [.white.opacity(0.1), .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: isTextFieldFocused ? 1.5 : 0.5
                                            )
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.controlBackgroundColor))
                                    .stroke(isTextFieldFocused ? .blue : .clear, lineWidth: 1)
                            }
                        }
                }
                .padding(.horizontal, 20)
                
                // Aufgabenliste
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(taskManager.tasks) { task in
                            AppTaskRowView(
                                task: task,
                                isHovered: hoveredTask == task.id,
                                onDelete: {
                                    withAnimation(.spring(response: 0.3)) {
                                        taskManager.deleteTask(task)
                                    }
                                }
                            )
                            .onHover { isHovering in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredTask = isHovering ? task.id : nil
                                }
                            }
                        }
                        
                        if taskManager.tasks.isEmpty {
                            VStack(spacing: 12) {
                                if #available(macOS 15.0, *) {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary)
                                        .symbolEffect(.pulse.wholeSymbol, options: .repeating)
                                } else {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Noch keine Aufgaben heute")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("Füge deine erste Aufgabe hinzu!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 32)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 150)
                
                Spacer(minLength: 20)
            }
        }
        .frame(width: 400, height: 300)
        .background(Color.clear)
        .clipped()
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            taskManager.addTask(newTaskText.trimmingCharacters(in: .whitespacesAndNewlines))
            newTaskText = ""
        }
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
}

struct AppTaskRowView: View {
    let task: AppTask
    let isHovered: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if #available(macOS 15.0, *) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.bounce, value: task.id)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundColor(.green)
            }
            
            Text(task.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text(timeString(from: task.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
                .opacity(isHovered ? 0.5 : 1.0)
            
            if isHovered {
                Button(action: onDelete) {
                    if #available(macOS 15.0, *) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce, value: isHovered)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            if #available(macOS 15.0, *) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                .white.opacity(isHovered ? 0.15 : 0.05),
                                lineWidth: 0.5
                            )
                    }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.controlBackgroundColor).opacity(isHovered ? 0.8 : 0.6))
            }
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Task Model direkt hier
struct AppTask: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    
    init(text: String, timestamp: Date) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
    }
}

// TaskManager direkt hier
class AppTaskManager: ObservableObject {
    @Published var tasks: [AppTask] = []
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "daily_tasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(_ text: String) {
        let task = AppTask(text: text, timestamp: Date())
        tasks.append(task)
        saveTasks()
    }
    
    func deleteTask(_ task: AppTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([AppTask].self, from: data) {
            tasks = decoded
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    var hotKey: HotKey!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Daily App startet...")
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
        
        // Popover konfigurieren mit Liquid Glass
        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 320)
        popover.behavior = .transient
        popover.animates = true
        
        if #available(macOS 15.0, *) {
            let contentView = AppContentView()
            let hostingController = NSHostingController(rootView: contentView)
            
            popover.contentViewController = hostingController
            popover.appearance = NSAppearance(named: .vibrantDark)
            
            // Entferne nur die äußeren Popover-Schatten und Hintergrund
            hostingController.view.wantsLayer = true
            hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        } else {
            // Fallback für ältere Versionen
            let viewController = NSViewController()
            let label = NSTextField(labelWithString: "Diese App benötigt macOS Tahoe (15.0) oder neuer")
            label.frame = NSRect(x: 50, y: 100, width: 320, height: 100)
            viewController.view = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 320))
            viewController.view.addSubview(label)
            popover.contentViewController = viewController
        }
        
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
        if #available(macOS 15.0, *) {
            if let button = statusBarItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                
                // Entferne den äußeren Popover-Rahmen nach dem Anzeigen
                DispatchQueue.main.async {
                    if let popoverWindow = self.popover.value(forKey: "popoverWindow") as? NSWindow {
                        // Mache das Popover-Fenster transparent
                        popoverWindow.backgroundColor = NSColor.clear
                        popoverWindow.isOpaque = false
                        popoverWindow.hasShadow = false
                        
                        // Entferne auch den ContentView-Hintergrund des Popovers
                        if let contentView = popoverWindow.contentView {
                            contentView.wantsLayer = true
                            contentView.layer?.backgroundColor = NSColor.clear.cgColor
                            contentView.layer?.borderWidth = 0
                        }
                        
                        // Versuche, das Popover-Background komplett zu deaktivieren
                        if let popoverView = popoverWindow.contentView?.subviews.first {
                            popoverView.wantsLayer = true
                            popoverView.layer?.backgroundColor = NSColor.clear.cgColor
                            popoverView.layer?.borderWidth = 0
                        }
                    }
                }
                
                eventMonitor?.start()
            }
        } else {
            print("Diese App benötigt macOS Tahoe (15.0) oder neuer")
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
