import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
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
                            TaskRowView(
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
                                    .foregroundColor(.tertiary)
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

struct TaskRowView: View {
    let task: Task
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

#Preview {
    ContentView()
        .frame(width: 400, height: 300)
}
