import Cocoa
import SwiftUI
import HotKey

// ContentView direkt hier definieren für bessere Kompatibilität
struct AppContentView: View {
    @StateObject private var taskManager = AppTaskManager()
    @State private var newTaskText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var hoveredTask: UUID? = nil
    @State private var animatingTaskId: UUID? = nil
    @State private var showExtendedView = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 16) {
                AppHeaderView(
                    showExtendedView: $showExtendedView,
                    taskCount: taskManager.tasks.count
                )
                AppInputFieldView(
                    newTaskText: $newTaskText,
                    isTextFieldFocused: $isTextFieldFocused,
                    onAddTask: addTask
                )
                
                if showExtendedView {
                    AppExtendedTaskListView(
                        taskManager: taskManager,
                        hoveredTask: $hoveredTask,
                        animatingTaskId: $animatingTaskId
                    )
                } else {
                    AppTaskListView(
                        taskManager: taskManager,
                        hoveredTask: $hoveredTask,
                        animatingTaskId: $animatingTaskId
                    )
                }
                
                Spacer(minLength: 20)
            }
        }
        .frame(width: 400, height: showExtendedView ? 500 : 300)
        .background(Color.clear)
        .clipped()
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let taskText = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTask = taskManager.createTask(taskText)
        
        // Animation: Task "fliegt" vom Input Field weg
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            animatingTaskId = newTask.id
        }
        
        // Task zur Liste hinzufügen mit Delay für smooth Animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                taskManager.addTask(newTask)
                newTaskText = ""
            }
            
            // Animation-State nach kurzer Zeit zurücksetzen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animatingTaskId = nil
            }
        }
    }
}

// Separater Background View
struct AppBackgroundView: View {
    var body: some View {
        if #available(macOS 15.0, *) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.7)
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.blue.opacity(0.04),
                            Color.purple.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.08),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                        .padding(1)
                }
        } else {
            Rectangle()
                .fill(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
        }
    }
}

// Separater Header View  
struct AppHeaderView: View {
    @Binding var showExtendedView: Bool
    let taskCount: Int
    
    var body: some View {
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
            
            VStack(alignment: .leading, spacing: showExtendedView ? 2 : 0) {
                Text("Daily Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if showExtendedView && taskCount > 0 {
                    Text("\(taskCount) \(taskCount == 1 ? "Aufgabe" : "Aufgaben")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Toggle Button für Extended View
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showExtendedView.toggle()
                }
            }) {
                if #available(macOS 15.0, *) {
                    Image(systemName: showExtendedView ? "list.bullet.rectangle" : "list.bullet")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.bounce, value: showExtendedView)
                } else {
                    Image(systemName: showExtendedView ? "list.bullet.rectangle" : "list.bullet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .help(showExtendedView ? "Kompakte Ansicht" : "Erweiterte Ansicht")
            
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
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
}

// Separater Input Field View
struct AppInputFieldView: View {
    @Binding var newTaskText: String
    @FocusState.Binding var isTextFieldFocused: Bool
    let onAddTask: () -> Void
    
    var body: some View {
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
            
            ZStack {
                TextField("Was hast du heute gemacht?", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($isTextFieldFocused)
                    .onSubmit(onAddTask)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background {
                        AppTextFieldBackground(isTextFieldFocused: isTextFieldFocused)
                    }
            }
        }
        .padding(.horizontal, 20)
    }
}

// Separater TextField Background
struct AppTextFieldBackground: View {
    let isTextFieldFocused: Bool
    
    var body: some View {
        if #available(macOS 15.0, *) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            focusedBorderGradient,
                            lineWidth: isTextFieldFocused ? 1.5 : 0.5
                        )
                        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
                }
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
                .stroke(isTextFieldFocused ? .blue : .clear, lineWidth: 1)
        }
    }
    
    @available(macOS 15.0, *)
    private var focusedBorderGradient: AnyShapeStyle {
        if isTextFieldFocused {
            return AnyShapeStyle(.angularGradient(
                colors: [.blue, .purple, .cyan, .blue],
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            ))
        } else {
            return AnyShapeStyle(.linearGradient(
                colors: [.white.opacity(0.1), .clear],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
    }
}

// Separater Task List View
struct AppTaskListView: View {
    @ObservedObject var taskManager: AppTaskManager
    @Binding var hoveredTask: UUID?
    @Binding var animatingTaskId: UUID?
    
    private var limitedTasks: [AppTask] {
        Array(taskManager.tasks.prefix(10))
    }
    
    private let compact = true
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(limitedTasks) { task in
                    AppTaskRowView(
                        task: task,
                        isHovered: hoveredTask == task.id,
                        isAnimating: animatingTaskId == task.id,
                        compact: true,
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
                    // Fly-in Animation für neue Tasks
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
                
                if taskManager.tasks.count > 10 {
                    Text("... und \(taskManager.tasks.count - 10) weitere")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
                
                if taskManager.tasks.isEmpty {
                    VStack(spacing: 8) {
                        if #available(macOS 15.0, *) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                                .symbolEffect(.pulse.wholeSymbol, options: .repeating)
                        } else {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Noch keine Aufgaben heute")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text("Füge deine erste Aufgabe hinzu!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: compact ? 120 : 150)
    }
}

// Erweiterte Task List View mit Datums-Gruppierung
struct AppExtendedTaskListView: View {
    @ObservedObject var taskManager: AppTaskManager
    @Binding var hoveredTask: UUID?
    @Binding var animatingTaskId: UUID?
    
    private var groupedTasks: [(String, [AppTask])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: taskManager.tasks) { task in
            calendar.startOfDay(for: task.timestamp)
        }
        
        return grouped.map { (date, tasks) in
            let formatter = DateFormatter()
            let dateString: String
            
            if calendar.isDateInToday(date) {
                dateString = "Heute"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Gestern"
            } else {
                formatter.dateFormat = "EEEE, dd.MM.yyyy"
                dateString = formatter.string(from: date)
            }
            
            return (dateString, tasks.sorted { $0.timestamp > $1.timestamp })
        }.sorted { group1, group2 in
            let date1 = taskManager.tasks.first { task in
                group1.1.contains { $0.id == task.id }
            }?.timestamp ?? Date.distantPast
            let date2 = taskManager.tasks.first { task in
                group2.1.contains { $0.id == task.id }
            }?.timestamp ?? Date.distantPast
            return date1 > date2
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groupedTasks, id: \.0) { dateString, tasks in
                    VStack(alignment: .leading, spacing: 8) {
                        // Datums-Header mit Löschen-Button
                        HStack {
                            Text(dateString)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("(\(tasks.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    for task in tasks {
                                        taskManager.deleteTask(task)
                                    }
                                }
                            }) {
                                if #available(macOS 15.0, *) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.red.opacity(0.7))
                                        .symbolEffect(.bounce, value: tasks.count)
                                } else {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                            .buttonStyle(.plain)
                            .help("Alle Aufgaben von \(dateString) löschen")
                        }
                        .padding(.horizontal, 20)
                        
                        // Tasks für dieses Datum
                        LazyVStack(spacing: 6) {
                            ForEach(tasks) { task in
                                AppTaskRowView(
                                    task: task,
                                    isHovered: hoveredTask == task.id,
                                    isAnimating: animatingTaskId == task.id,
                                    showDate: true,
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
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                if taskManager.tasks.isEmpty {
                    VStack(spacing: 8) {
                        if #available(macOS 15.0, *) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                                .symbolEffect(.pulse.wholeSymbol, options: .repeating)
                        } else {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Noch keine Aufgaben")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text("Füge deine erste Aufgabe hinzu!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 32)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .frame(maxHeight: 350)
    }
}

struct AppTaskRowView: View {
    let task: AppTask
    let isHovered: Bool
    let isAnimating: Bool
    let showDate: Bool
    let compact: Bool
    let onDelete: () -> Void
    
    init(task: AppTask, isHovered: Bool, isAnimating: Bool, showDate: Bool = true, compact: Bool = false, onDelete: @escaping () -> Void) {
        self.task = task
        self.isHovered = isHovered
        self.isAnimating = isAnimating
        self.showDate = showDate
        self.compact = compact
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if #available(macOS 15.0, *) {
                Image(systemName: "checkmark.circle.fill")
                    .font(compact ? .caption : .body)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.bounce, value: task.id)
                    .symbolEffect(.pulse, options: .repeating, value: isAnimating)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(compact ? .caption : .body)
                    .foregroundColor(.green)
            }
            
            Text(task.text)
                .font(compact ? .body : .body)
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .truncationMode(.tail)
            
            Spacer()
            
            if compact {
                // Kompakte Ansicht: Alles in einer Zeile
                HStack(spacing: 4) {
                    Text(compactDateString(from: task.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                    
                    Text(timeString(from: task.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 0.5 : 1.0)
                }
            } else if showDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dateString(from: task.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                    
                    Text(timeString(from: task.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 0.5 : 1.0)
                }
            } else {
                Text(timeString(from: task.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(isHovered ? 0.5 : 1.0)
            }
            
            if isHovered {
                Button(action: onDelete) {
                    if #available(macOS 15.0, *) {
                        Image(systemName: "xmark.circle.fill")
                            .font(compact ? .caption : .body)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce, value: isHovered)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(compact ? .caption : .body)
                            .foregroundColor(.red)
                    }
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, compact ? 6 : 10)
        .background {
            if #available(macOS 15.0, *) {
                RoundedRectangle(cornerRadius: compact ? 8 : 10)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: compact ? 8 : 10)
                            .strokeBorder(
                                .white.opacity(isHovered ? 0.15 : (isAnimating ? 0.2 : 0.05)),
                                lineWidth: isAnimating ? 1.0 : 0.5
                            )
                    }
            } else {
                RoundedRectangle(cornerRadius: compact ? 6 : 8)
                    .fill(Color(.controlBackgroundColor).opacity(isHovered ? 0.8 : 0.6))
            }
        }
        .scaleEffect(isHovered ? 1.02 : (isAnimating ? 1.05 : 1.0))
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func dateString(from date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDateInToday(date) {
            return "Heute"
        } else if calendar.isDateInYesterday(date) {
            return "Gestern"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        }
    }
    
    private func compactDateString(from date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Heute"
        } else if calendar.isDateInYesterday(date) {
            return "Gestern"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        }
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
    
    func createTask(_ text: String) -> AppTask {
        return AppTask(text: text, timestamp: Date())
    }
    
    func addTask(_ text: String) {
        let task = AppTask(text: text, timestamp: Date())
        tasks.insert(task, at: 0)
        saveTasks()
    }
    
    func addTask(_ task: AppTask) {
        tasks.insert(task, at: 0)
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
        Version 0.2.0
        
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
