# Daily App - macOS Liquid Glass Edition

Eine native macOS Menu Bar Anwendung zum Tracken täglicher Aufgaben mit einem Spotlight-ähnlichen Interface und modernem Liquid Glass Design.

![Daily App Demo](https://img.shields.io/badge/macOS-Tahoe%2015.0+-blue?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green?style=for-the-badge)

## ✨ Features

- **� Liquid Glass Design** - Modernster macOS Tahoe Look mit Transparenz-Effekten
- **�🏠 Menu Bar Integration** - Lebt dezent in der macOS Menüleiste  
- **⚡ Spotlight-ähnliches Interface** - Schnelle Texteingabe mit vertrautem Design
- **📝 Tägliche Aufgaben** - Erfasse kurze Notizen über deine täglichen Aktivitäten
- **💾 Persistente Speicherung** - Daten werden automatisch gespeichert
- **⌨️ Globales Tastenkürzel** - `Cmd+Shift+D` funktioniert systemweit
- **🖱️ Smart Menu System** - Linksklick = Toggle, Rechtsklick = Kontextmenü
- **🎬 Smooth Animations** - Moderne Übergänge und Symbol-Effekte
- **🌙 Dark Mode Ready** - Perfekte Integration in macOS Dark Mode

## 🔧 Installation

### Automatischer Download (Empfohlen)
1. Gehe zu [Releases](../../releases)
2. Lade die neueste `Daily-App.dmg` herunter
3. Öffne das DMG und ziehe die App in den Applications Ordner
4. Starte die App - das Icon erscheint in der Menüleiste
5. Drücke `Cmd+Shift+D` zum ersten Mal öffnen

### Manueller Build
```bash
git clone https://github.com/[dein-username]/macos-daily-app.git
cd macos-daily-app
swift build -c release
./.build/release/DailyApp
```

## 📋 Systemanforderungen

- **macOS Tahoe (15.0) oder neuer** für Liquid Glass Effekte
- **Apple Silicon oder Intel Mac**
- Für Entwicklung: **Xcode 15.0+** und **Swift 5.9+**

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
