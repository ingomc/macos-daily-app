import Cocoa
import SwiftUI
import HotKey
import CoreImage
import CoreImage.CIFilterBuiltins

// Version Fallback Funktionen für CI/CD Builds
func getAppVersion() -> String {
    // Versuche zuerst AppVersion zu verwenden, falls verfügbar
    if let appVersionType = NSClassFromString("AppVersion") {
        if let version = appVersionType.value(forKey: "fullVersion") as? String {
            return version
        }
    }
    return "v0.4.0-dev"
}

func getBuildInfo() -> String {
    if let appVersionType = NSClassFromString("AppVersion") {
        if let buildDate = appVersionType.value(forKey: "buildDate") as? String {
            return buildDate
        }
    }
    return "CI Build \(Date().formatted(.dateTime.year().month().day()))"
}

func getGitInfo() -> String {
    if let appVersionType = NSClassFromString("AppVersion") {
        if let gitHash = appVersionType.value(forKey: "gitHash") as? String {
            return gitHash
        }
    }
    return "Unknown"
}

// ContentView direkt hier definieren für bessere Kompatibilität
struct AppContentView: View {
    @StateObject private var taskManager = AppTaskManager()
    @State private var newTaskText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var hoveredTask: UUID? = nil
    @State private var animatingTaskId: UUID? = nil
    @State private var liquidGlassOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            AppBackgroundView()
                .opacity(0.1 + liquidGlassOpacity * 0.02) // Noch transparenter
            
            VStack(spacing: 20) {
                AppHeaderView(taskCount: taskManager.tasks.count)
                
                AppInputFieldView(
                    newTaskText: $newTaskText,
                    isTextFieldFocused: $isTextFieldFocused,
                    onAddTask: addTask
                )
                
                AppExtendedTaskListView(
                    taskManager: taskManager,
                    hoveredTask: $hoveredTask,
                    animatingTaskId: $animatingTaskId
                )
                
                Spacer(minLength: 10) // Weniger Spacer für mehr ScrollView-Platz
            }
        }
        .frame(width: 400, height: 380) // Reduzierte Höhe für bessere Bildschirm-Positionierung
        .background(Color.clear)
        .clipped()
        .onAppear {
            isTextFieldFocused = true
            
            // Subtile Liquid Glass Atmung-Animation
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                liquidGlassOpacity = 0.15
            }
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

// Separater Background View mit Liquid Glass Effekt
struct AppBackgroundView: View {
    @State private var glassIntensity: Double = 0.0
    
    var body: some View {
        if #available(macOS 15.0, *) {
            LiquidGlassBackground(glassIntensity: glassIntensity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                        glassIntensity = 0.3
                    }
                }
        } else {
            FallbackBackground()
        }
    }
}

// Liquid Glass Background für macOS 15+
@available(macOS 15.0, *)
struct LiquidGlassBackground: View {
    let glassIntensity: Double
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .background {
                LiquidGlassLayer(glassIntensity: glassIntensity)
            }
    }
}

// Liquid Glass Material Layer - Aufgeteilt für bessere Kompilierung
@available(macOS 15.0, *)
struct LiquidGlassLayer: View {
    let glassIntensity: Double
    
    var body: some View {
        LiquidGlassBase()
            .overlay {
                LiquidGlassOverlays(glassIntensity: glassIntensity)
            }
            .overlay {
                LiquidGlassBorders()
            }
    }
}

@available(macOS 15.0, *)
struct LiquidGlassBase: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.clear) // Komplett transparent als Basis
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.clear)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.08))
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
            .shadow(color: .blue.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

@available(macOS 15.0, *)
struct LiquidGlassOverlays: View {
    let glassIntensity: Double
    
    var body: some View {
        Group {
            RefractionOverlay()
            LiquidFlowOverlay(glassIntensity: glassIntensity)
            HighlightBorder()
            InnerGlow()
        }
    }
}

@available(macOS 15.0, *)
struct LiquidGlassBorders: View {
    var body: some View {
        Group {
            // Erste Reflexions-Schicht
            MainWindowReflection1()
            
            // Zweite Reflexions-Schicht
            MainWindowReflection2()
            
            // Dritte animierte Schicht
            MainWindowReflection3()
        }
    }
}

@available(macOS 15.0, *)
struct MainWindowReflection1: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.6),
                        .cyan.opacity(0.3),
                        .white.opacity(0.4),
                        .blue.opacity(0.2),
                        .white.opacity(0.5),
                        .purple.opacity(0.15),
                        .white.opacity(0.45)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ),
                lineWidth: 1.2
            )
            .padding(2)
    }
}

@available(macOS 15.0, *)
struct MainWindowReflection2: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.35),
                        .clear,
                        .mint.opacity(0.2),
                        .clear,
                        .white.opacity(0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.8
            )
            .padding(4)
    }
}

@available(macOS 15.0, *)
struct MainWindowReflection3: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .strokeBorder(
                AngularGradient(
                    colors: [
                        .white.opacity(0.3),
                        .cyan.opacity(0.15),
                        .blue.opacity(0.1),
                        .purple.opacity(0.08),
                        .white.opacity(0.25),
                        .mint.opacity(0.12),
                        .white.opacity(0.3)
                    ],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 0.6
            )
            .padding(1)
    }
}

// Refraktions-Effekt Overlay
@available(macOS 15.0, *)
struct RefractionOverlay: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.08), // Verstärkte Reflexionen
                Color.cyan.opacity(0.05),
                Color.white.opacity(0.04),
                Color.purple.opacity(0.02),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.screen)
    }
}

// Liquid Flow Animation Overlay
@available(macOS 15.0, *)
struct LiquidFlowOverlay: View {
    let glassIntensity: Double
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.04 + glassIntensity * 0.03), // Verstärkte animierte Reflexionen
                Color.cyan.opacity(0.02 + glassIntensity * 0.015),
                Color.white.opacity(0.015 + glassIntensity * 0.01)
            ],
            startPoint: UnitPoint(x: -0.3 + glassIntensity, y: -0.3 + glassIntensity),
            endPoint: UnitPoint(x: 1.3 + glassIntensity, y: 1.3 + glassIntensity)
        )
        .blendMode(.overlay)
    }
}

// Hochglanz Border - VERSTÄRKT
@available(macOS 15.0, *)
struct HighlightBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.65), // Noch stärkere Glasreflexionen
                        .white.opacity(0.5),
                        .cyan.opacity(0.25),
                        .white.opacity(0.45),
                        .blue.opacity(0.15),
                        .purple.opacity(0.12),
                        .white.opacity(0.55),
                        .mint.opacity(0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2.2 // Noch dickerer Rahmen für maximale Prominenz
            )
    }
}

// Innerer Glasglanz - VERSTÄRKT
@available(macOS 15.0, *)
struct InnerGlow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .strokeBorder(.white.opacity(0.25), lineWidth: 1.5) // Deutlich sichtbare innere Reflexion
            .padding(1.5)
            .overlay {
                // Zusätzlicher innerer Glanz für mehr Tiefe
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.cyan.opacity(0.15), lineWidth: 0.8)
                    .padding(3)
            }
    }
}

// Fallback für ältere macOS Versionen
struct FallbackBackground: View {
    var body: some View {
        Rectangle()
            .fill(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 10)
    }
}

// Separater Header View  
struct AppHeaderView: View {
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if taskCount > 0 {
                    Text("\(taskCount) \(taskCount == 1 ? "Aufgabe" : "Aufgaben")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(currentDateString())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    if #available(macOS 15.0, *) {
                        LiquidGlassDateBadge()
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
        VStack(spacing: 8) {
            TextField("Was hast du heute gemacht?", text: $newTaskText)
                .textFieldStyle(.plain)
                .font(.title3) // Größere Schrift
                .fontWeight(.medium)
                .focused($isTextFieldFocused)
                .onSubmit(onAddTask)
                .padding(.vertical, 16) // Mehr Padding
                .padding(.horizontal, 20)
                .background {
                    AppTextFieldBackground(isTextFieldFocused: isTextFieldFocused)
                }
        }
        .padding(.horizontal, 20)
    }
}

// Separater TextField Background mit Liquid Glass Effekt
struct AppTextFieldBackground: View {
    let isTextFieldFocused: Bool
    
    var body: some View {
        if #available(macOS 15.0, *) {
            RoundedRectangle(cornerRadius: 16) // Größerer Radius
                .fill(.clear) // Transparent als Basis
                .background {
                    // Klares Glas ohne Material
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.clear)
                        .background {
                            // Nur minimale Glasschicht
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08)) // Etwas sichtbarer
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            focusedBorderGradient,
                            lineWidth: isTextFieldFocused ? 2.0 : 1.0 // Dickerer Border
                        )
                        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
                }
                .overlay {
                    // Innerer Glasglanz für Tiefe
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.6) // Sichtbarer
                        .padding(1.5)
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
                colors: [
                    .blue.opacity(0.8), 
                    .cyan.opacity(0.6), 
                    .purple.opacity(0.7), 
                    .blue.opacity(0.8)
                ],
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            ))
        } else {
            return AnyShapeStyle(.linearGradient(
                colors: [.white.opacity(0.2), .white.opacity(0.05), .clear],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
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
        .frame(maxHeight: 250) // Vergrößerte ScrollView für mehr Platz bis zum Fensterrand
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
            AppTaskRowBackground(
                isHovered: isHovered,
                isAnimating: isAnimating,
                compact: compact
            )
        }
        .scaleEffect(isHovered ? 1.02 : (isAnimating ? 1.05 : 1.0))
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
    }
}

// Separater Task Row Background mit Liquid Glass Effekt
struct AppTaskRowBackground: View {
    let isHovered: Bool
    let isAnimating: Bool
    let compact: Bool
    
    var body: some View {
        if #available(macOS 15.0, *) {
            RoundedRectangle(cornerRadius: compact ? 10 : 12)
                .fill(.clear) // Transparent als Basis
                .background {
                    // Klares Glas ohne Material
                    RoundedRectangle(cornerRadius: compact ? 10 : 12)
                        .fill(.clear)
                        .background {
                            // Nur minimale Glasschicht
                            RoundedRectangle(cornerRadius: compact ? 10 : 12)
                                .fill(Color.white.opacity(0.05))
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: compact ? 10 : 12)
                        .strokeBorder(
                            liquidGlassBorder,
                            lineWidth: isAnimating ? 1.2 : (isHovered ? 0.8 : 0.4)
                        )
                }
                .overlay {
                    // Innerer Glasglanz
                    RoundedRectangle(cornerRadius: compact ? 8 : 10)
                        .strokeBorder(.white.opacity(0.05), lineWidth: 0.3) // Dezente Reflexion
                        .padding(1)
                }
        } else {
            RoundedRectangle(cornerRadius: compact ? 6 : 8)
                .fill(Color(.controlBackgroundColor).opacity(isHovered ? 0.8 : 0.6))
        }
    }
    
    @available(macOS 15.0, *)
    private var liquidGlassBorder: AnyShapeStyle {
        if isAnimating {
            return AnyShapeStyle(.angularGradient(
                colors: [
                    .blue.opacity(0.6),
                    .cyan.opacity(0.5),
                    .mint.opacity(0.4),
                    .blue.opacity(0.6)
                ],
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            ))
        } else if isHovered {
            return AnyShapeStyle(.linearGradient(
                colors: [.white.opacity(0.25), .cyan.opacity(0.15), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        } else {
            return AnyShapeStyle(.linearGradient(
                colors: [.white.opacity(0.12), .white.opacity(0.04), .clear],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
    }
}

// Liquid Glass Date Badge
@available(macOS 15.0, *)
struct LiquidGlassDateBadge: View {
    var body: some View {
        Capsule()
            .fill(.clear)
            .background {            Capsule()
                .fill(.clear)
                .background {
                    // Klares Glas ohne Material
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                }
            }
            .overlay {            Capsule()
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.4) // Dezente Badge-Reflexion
            }
    }
}

// Hilfsfunktionen für AppTaskRowView 
extension AppTaskRowView {
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func dateString(from date: Date) -> String {
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
        popover.contentSize = NSSize(width: 400, height: 380) // Kompakte Standardgröße
        popover.behavior = .transient
        popover.animates = true
        
        if #available(macOS 15.0, *) {
            let contentView = AppContentView()
            let hostingController = NSHostingController(rootView: contentView)
            
            popover.contentViewController = hostingController
            // Komplett transparentes Popover - kein eigenes Styling
            popover.appearance = nil
            
            // Minimale View-Anpassungen für bessere Glaseffekt-Integration
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
                // Bildschirm-Grenzen prüfen für bessere Positionierung
                let screenRect = NSScreen.main?.visibleFrame ?? NSRect.zero
                let buttonRect = button.convert(button.bounds, to: nil)
                let windowFrame = button.window?.convertToScreen(buttonRect) ?? NSRect.zero
                
                // Kompakte Popover-Größe für bessere Bildschirm-Anpassung
                let contentHeight: CGFloat = 380
                let maxHeight = screenRect.height - 120 // Mehr Abstand vom Bildschirmrand
                let adjustedHeight = min(contentHeight, maxHeight)
                
                popover.contentSize = NSSize(width: 400, height: adjustedHeight)
                
                // Smart positioning - prüfe verfügbaren Platz
                let spaceBelow = windowFrame.minY - screenRect.minY
                let spaceAbove = screenRect.maxY - windowFrame.maxY
                
                // Wähle die Position mit mehr Platz
                let preferredEdge: NSRectEdge
                if spaceBelow >= adjustedHeight + 20 {
                    preferredEdge = .minY // Nach unten öffnen
                } else if spaceAbove >= adjustedHeight + 20 {
                    preferredEdge = .maxY // Nach oben öffnen
                } else {
                    // Falls beides knapp ist, nehme die größere Seite
                    preferredEdge = spaceBelow > spaceAbove ? .minY : .maxY
                }
                
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: preferredEdge)
                
                // Komplett transparentes Popover - nur interne Glaseffekte sichtbar
                DispatchQueue.main.async {
                    if let popoverWindow = self.popover.value(forKey: "popoverWindow") as? NSWindow {
                        // Komplett transparent - kein Popover-Styling
                        popoverWindow.backgroundColor = NSColor.clear
                        popoverWindow.isOpaque = false
                        popoverWindow.hasShadow = false // Kein Schatten
                        
                        // Entferne alle Popover-Hintergründe
                        if let contentView = popoverWindow.contentView {
                            contentView.wantsLayer = true
                            contentView.layer?.backgroundColor = NSColor.clear.cgColor
                            
                            // Entferne auch Subview-Backgrounds
                            for subview in contentView.subviews {
                                subview.wantsLayer = true
                                subview.layer?.backgroundColor = NSColor.clear.cgColor
                            }
                        }
                    }
                }
                
                eventMonitor?.start()
            }
        } else {
            print("Diese App benötigt macOS Tahoe (15.0) oder neuer für Liquid Glass Effekte")
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
        Version \(getAppVersion())
        Build: \(getBuildInfo())
        Git: \(getGitInfo())
        
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
