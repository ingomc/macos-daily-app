# macOS Daily App

Eine native macOS Menu Bar Anwendung zum Tracken täglicher Aufgaben mit einem Spotlight-ähnlichen Interface.

## Features

- **🏠 Menu Bar Integration** - Lebt dezent in der macOS Menüleiste
- **⚡ Spotlight-ähnliches Interface** - Schnelle Texteingabe mit vertrautem Design
- **📝 Tägliche Aufgaben** - Erfasse kurze Notizen über deine täglichen Aktivitäten
- **💾 Persistente Speicherung** - Daten werden in UserDefaults gespeichert
- **🎨 Moderne SwiftUI UI** - Schönes, natives macOS Design mit Animationen
- **⌨️ Globales Tastenkürzel** - Cmd+Shift+D funktioniert systemweit
- **🖱️ Smart Menu System** - Linksklick = Toggle, Rechtsklick = Kontextmenü
- **🎬 Smooth Animations** - Moderne Übergänge beim Hinzufügen/Entfernen

## Systemanforderungen

- macOS 14.0 oder neuer (Sonoma/Sequoia)
- Xcode 15.0 oder neuer (für Entwicklung)

## Installation & Entwicklung

### Vorbereitung

1. Stelle sicher, dass Xcode installiert und die Lizenz akzeptiert ist:
   ```bash
   sudo xcodebuild -license accept
   ```

### Build & Run

```bash
# App kompilieren
swift build

# App starten
swift run
```

### Entwicklung in Xcode

Du kannst das Projekt auch in Xcode öffnen:

```bash
open Package.swift
```

## Nutzung

1. **App starten** - Die App läuft im Hintergrund und zeigt ein Icon in der Menüleiste
2. **Popup öffnen** - Klicke auf das 📝 Icon in der Menüleiste
3. **Aufgabe hinzufügen** - Gib eine kurze Beschreibung ein und drücke Enter
4. **Aufgaben verwalten** - Lösche Aufgaben mit dem X-Button oder alle mit "Alle löschen"

## Tastenkürzel & Navigation

- **Popup öffnen/schließen** 
  - 🖱️ Klick auf Menüleisten-Icon
  - ⌨️ **Cmd+Shift+D** (Global Hotkey)
- **Aufgabe hinzufügen** - Enter im Eingabefeld
- **Popup schließen** - ESC-Taste oder Klick außerhalb
- **Kontextmenü** - Rechtsklick auf Menüleisten-Icon
- **Text löschen** - X-Button im Eingabefeld

## Projektstruktur

```
Sources/DailyApp/
├── main.swift          # Entry Point
├── AppDelegate.swift   # Menu Bar & Popover Management
├── ContentView.swift   # SwiftUI Hauptinterface
├── TaskManager.swift   # Datenmodell & Persistierung
├── EventMonitor.swift  # Klick-outside-Detection
└── DailyApp.swift      # Zusätzliche App-Konfiguration
```

## Technische Details

- **Swift Package Manager** - Modernes Swift-Projekt-Setup
- **SwiftUI + AppKit** - Hybrid-Ansatz für Menu Bar Apps
- **HotKey Library** - Globale Tastenkürzel-Unterstützung
- **UserDefaults** - Einfache, native Datenpersistierung
- **NSStatusItem** - Menu Bar Integration
- **NSPopover** - Spotlight-ähnliches Popup
- **Concurrency** - Moderne async/await und MainActor-Patterns
- **Material Design** - Native macOS Blur-Effekte

## Zukünftige Features

- [ ] Aufgaben-Kategorien & Tags
- [ ] Export zu verschiedenen Formaten
- [ ] Tägliche/Wöchentliche Statistiken  
- [ ] Notifikationen & Reminders
- [ ] iCloud Sync zwischen Geräten
- [ ] Themes & Customization
- [ ] Tastatur-Navigation für Power-User

## Entwicklung

### Debugging

```bash
# Mit Verbose-Output
swift run --verbose

# Debug-Build
swift build --configuration debug
```

### Architektur

Die App folgt dem MVVM-Pattern:
- **Model**: `DailyTask` Struct
- **ViewModel**: `TaskManager` ObservableObject  
- **View**: SwiftUI `ContentView`
- **Integration**: AppKit `AppDelegate` für Menu Bar

## Lizenz

MIT License - Siehe LICENSE Datei für Details.

---

**Entwickelt mit ❤️ für macOS**
