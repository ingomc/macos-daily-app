# Daily App - macOS Liquid Glass Edition

Eine native macOS Menu Bar Anwendung zum Tracken täglicher Aufgaben mit einem Spotlight-ähnlichen Interface und modernem Liquid Glass Design.

![Daily App Demo](https://img.shields.io/badge/macOS-Tahoe%2015.0+-blue?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0+-orange?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-v0.3.0-brightgreen?style=for-the-badge)

## ✨ Features

- **🌟 Liquid Glass Design** - Modernster macOS Tahoe Look mit Transparenz-Effekten
- **🏠 Menu Bar Integration** - Lebt dezent in der macOS Menüleiste  
- **⚡ Spotlight-ähnliches Interface** - Schnelle Texteingabe mit vertrautem Design
- **📝 Tägliche Aufgaben** - Erfasse kurze Notizen über deine täglichen Aktivitäten
- **💾 Persistente Speicherung** - Daten werden automatisch gespeichert
- **⌨️ Globales Tastenkürzel** - `Cmd+Shift+D` funktioniert systemweit
- **🖱️ Smart Menu System** - Linksklick = Toggle, Rechtsklick = Kontextmenü
- **🎬 Smooth Animations** - Moderne Übergänge und Symbol-Effekte
- **🌙 Dark Mode Ready** - Perfekte Integration in macOS Dark Mode
- **🔄 Auto-Versioning** - Automatische Versionsnummern aus Git Tags

## 🔧 Installation

### Automatischer Download (Empfohlen)
1. Gehe zu [Releases](../../releases)
2. Lade die neueste `Daily-App.dmg` herunter
3. Öffne das DMG und ziehe die App in den Applications Ordner
4. **Wichtig für unsignierte Apps**: Entferne die Quarantäne-Kennzeichnung:
   ```bash
   xattr -dr com.apple.quarantine "/Applications/Daily App.app"
   ```
5. Starte die App - das Icon erscheint in der Menüleiste
6. Drücke `Cmd+Shift+D` zum ersten Mal öffnen

> **⚠️ Hinweis zur Code-Signierung**: Da die App momentan nicht signiert ist, muss die Quarantäne-Kennzeichnung manuell entfernt werden. Dies ist ein einmaliger Vorgang nach der Installation.

### Manueller Build

#### Voraussetzungen
- macOS 15.0+ (Tahoe)
- Xcode 16.0+ 
- Swift 6.0+
- Git (für automatische Versionierung)

#### Build-Optionen

**Option 1: Mit Makefile (empfohlen)**
```bash
git clone https://github.com/[dein-username]/macos-daily-app.git
cd macos-daily-app

# Vollständiger Build mit automatischer Versionierung
make build

# Debug-Build
make debug

# Release-Build für Distribution
make release

# App ausführen
make run

# Projektstruktur aufräumen
make clean
```

**Option 2: Swift Package Manager**
```bash
git clone https://github.com/[dein-username]/macos-daily-app.git
cd macos-daily-app

# Debug Build
swift build

# Release Build  
swift build -c release

# App ausführen
.build/debug/DailyApp
```

#### Automatische Versionierung

Die App verwendet Git Tags für automatische Versionsnummern:

```bash
# Neue Version taggen
git tag v1.2.3
git push origin v1.2.3

# Build mit automatischer Version
make build
```

Das Makefile generiert automatisch `Sources/DailyApp/AppVersion.swift` basierend auf dem aktuellen Git Tag.

#### Release Process

Für detaillierte Informationen zum Release-Prozess, siehe [`RELEASE.md`](./RELEASE.md).

## 📋 Systemanforderungen

- **macOS Tahoe (15.0) oder neuer** für Liquid Glass Effekte
- **Apple Silicon oder Intel Mac**
- Für Entwicklung: **Xcode 16.0+** und **Swift 6.0+**

## 🛠️ Troubleshooting

### App lässt sich nicht öffnen
Falls die App nicht startet, versuche folgende Schritte:

1. **Quarantäne entfernen** (häufigster Fall):
   ```bash
   xattr -dr com.apple.quarantine "/Applications/Daily App.app"
   ```

2. **Berechtigungen prüfen**:
   ```bash
   chmod +x "/Applications/Daily App.app/Contents/MacOS/Daily App"
   ```

3. **Gatekeeper temporär deaktivieren**:
   ```bash
   sudo spctl --master-disable
   # Nach dem Starten der App wieder aktivieren:
   sudo spctl --master-enable
   ```

4. **App aus dem Terminal starten** (für Debug-Output):
   ```bash
   "/Applications/Daily App.app/Contents/MacOS/Daily App"
   ```

### Globales Tastenkürzel funktioniert nicht
- Gehe zu **Systemeinstellungen > Sicherheit & Datenschutz > Eingabehilfen**
- Füge "Daily App" zur Liste der erlaubten Apps hinzu
- Starte die App neu

### App erscheint nicht in der Menüleiste
- Überprüfe, ob die App läuft: `Activity Monitor` → "Daily App" suchen
- Starte die App neu oder führe sie aus dem Terminal aus

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
