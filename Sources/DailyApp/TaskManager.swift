import Foundation

struct DailyTask: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    
    init(text: String, timestamp: Date) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: timestamp)
    }
}

@available(macOS 14.0, *)
class TaskManager: ObservableObject {
    @Published var todaysTasks: [DailyTask] = []
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "daily_tasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(text: String) {
        let task = DailyTask(text: text, timestamp: Date())
        todaysTasks.insert(task, at: 0) // Neueste zuerst
        saveTasks()
    }
    
    func removeTask(_ task: DailyTask) {
        todaysTasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func clearAllTasks() {
        todaysTasks.removeAll()
        saveTasks()
    }
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(todaysTasks)
            userDefaults.set(data, forKey: tasksKey)
        } catch {
            print("Fehler beim Speichern der Aufgaben: \(error)")
        }
    }
    
    private func loadTasks() {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            return
        }
        
        do {
            let tasks = try JSONDecoder().decode([DailyTask].self, from: data)
            // Nur heutige Aufgaben laden
            let today = Calendar.current.startOfDay(for: Date())
            todaysTasks = tasks.filter { 
                Calendar.current.isDate($0.timestamp, inSameDayAs: today)
            }
        } catch {
            print("Fehler beim Laden der Aufgaben: \(error)")
        }
    }
}
