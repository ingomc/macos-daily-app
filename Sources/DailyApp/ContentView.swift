import SwiftUI

@available(macOS 14.0, *)
struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var newTaskText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Tägliche Aufgaben")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(DateFormatter.dateFormatter.string(from: Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            // Eingabefeld - Spotlight-ähnlich
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 16))
                
                TextField("Was machst du heute?", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addTask()
                    }
                    .onKeyPress(.escape) {
                        // ESC schließt das Popover
                        NSApp.sendAction(#selector(AppDelegate.closePopover), to: nil, from: nil)
                        return .handled
                    }
                
                if !newTaskText.isEmpty {
                    Button(action: { 
                        newTaskText = "" 
                        isTextFieldFocused = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Text löschen")
                }
            }
            .padding(12)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isTextFieldFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Task Liste
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(taskManager.todaysTasks) { task in
                        TaskRowView(task: task) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                taskManager.removeTask(task)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: taskManager.todaysTasks.count)
            }
            .frame(maxHeight: 200)
            
            if taskManager.todaysTasks.isEmpty {
                VStack {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Noch keine Aufgaben für heute")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Footer
            HStack {
                Text("\(taskManager.todaysTasks.count) Aufgaben heute")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                if !taskManager.todaysTasks.isEmpty {
                    Button("Alle löschen") {
                        taskManager.clearAllTasks()
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundColor(.red)
                }
                
                Text("⌘⇧D")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 400, height: 300)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func addTask() {
        let trimmedText = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            taskManager.addTask(text: trimmedText)
            newTaskText = ""
            isTextFieldFocused = true
        }
    }
}

@available(macOS 14.0, *)
struct TaskRowView: View {
    let task: DailyTask
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(.blue)
                .frame(width: 6, height: 6)
            
            Text(task.text)
                .font(.system(size: 14))
                .lineLimit(2)
            
            Spacer()
            
            Text(task.timeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .opacity(0.7)
            .help("Aufgabe löschen")
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
}

#if swift(>=5.9)
@available(macOS 14.0, *)
#Preview {
    ContentView()
}
#endif
