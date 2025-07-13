# Release Guide für Daily App

## Übersicht

Die Daily App verwendet automatische Versionsgenerierung basierend auf Git Tags. Dieser Guide beschreibt den kompletten Release-Prozess.

## Automatische Versionsgenerierung

### Wie es funktioniert
- **Version**: Aus dem neuesten Git Tag (z.B. `v0.3.0`)
- **Build Number**: Anzahl der Git Commits (`git rev-list --count HEAD`)
- **Git Hash**: Kurzer Commit Hash für Debug-Info
- **Build Date**: UTC Timestamp der Kompilierung
- **Dirty State**: `-dirty` Suffix bei uncommitted changes

### Generierte Version
```swift
struct AppVersion {
    static let version = "v0.3.0"           // Aus Git Tag
    static let buildNumber = "14"           // Commit Count
    static let gitHash = "4b20b90"          // Git Hash
    static let buildDate = "2025-07-13 23:20:36 UTC"
    
    static var fullVersion: String {        // "v0.3.0 (14)"
        return "\(version) (\(buildNumber))"
    }
}
```

## Release-Prozess

### 1. Vorbereitung

```bash
# Status prüfen
git status
git log --oneline -5

# Aktuelle Tags anzeigen
git tag -l | sort -V

# Änderungen committen
git add .
git commit -m "Prepare release v0.4.0"
```

### 2. Neuen Tag erstellen

```bash
# Interaktiv mit Makefile
make tag

# Oder manuell
git tag v0.4.0
git tag -a v0.4.0 -m "Release v0.4.0 - Liquid Glass UI improvements"
```

### 3. Build und Test

```bash
# Development Build mit neuer Version
make build

# Version prüfen (sollte neuen Tag zeigen)
cat Sources/DailyApp/AppVersion.swift

# App testen
make run
```

### 4. Release Build

```bash
# Optimierten Release Build erstellen
make release

# Binary prüfen
ls -la .build/release/DailyApp
```

### 5. Tag pushen

```bash
# Tags zum Remote Repository pushen
git push origin --tags

# Oder spezifischen Tag
git push origin v0.4.0

# Main branch pushen
git push origin main
```

### 6. GitHub Release (Optional)

1. Gehe zu GitHub → Releases → "Create a new release"
2. Wähle den neuen Tag aus
3. Release-Notes hinzufügen
4. Binary als Asset hochladen (optional)

## Makefile Commands

```bash
# Version generieren (automatisch vor Build)
make version

# Development Build
make build

# App starten
make run

# Release Build (optimiert)
make release

# Neuen Tag erstellen (interaktiv)
make tag

# Aufräumen
make clean

# Installation (nach Release Build)
make install
```

## Automatische Builds

### GitHub Actions CI/CD

Die App ist für automatische Builds in GitHub Actions vorbereitet:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Wichtig für Git History
      
      - name: Generate Version
        run: make version
      
      - name: Build Release
        run: make release
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: .build/release/DailyApp
```

### Fallback für CI/CD

Die App verwendet eine committed `AppVersion.swift` als Fallback:

- **Fallback-Version**: v0.4.0-dev (für CI/CD und Entwicklung)
- **Makefile überschreibt**: Lokale Builds generieren automatisch aktuelle Version
- **Git-Status**: AppVersion.swift wird committed aber lokal überschrieben

**Workflow**:
1. `AppVersion.swift` existiert immer als Fallback
2. `make build` überschreibt mit aktueller Git-Version  
3. CI/CD kann immer kompilieren, auch ohne Makefile
4. Entwickler bekommen automatisch die richtige Version

Dies löst das CI/CD-Problem komplett und ermöglicht sowohl lokale als auch automatisierte Builds.

## Versioning Schema

### Semantic Versioning
- `v1.0.0` - Major Release (Breaking Changes)
- `v0.4.0` - Minor Release (New Features)
- `v0.3.1` - Patch Release (Bug Fixes)

### Tag Format
- **Release**: `v0.4.0`
- **Pre-Release**: `v0.4.0-beta.1`
- **Hot Fix**: `v0.3.1`

## Troubleshooting

### Keine Tags vorhanden
```bash
# Ersten Tag erstellen
git tag v0.1.0
make version  # Sollte jetzt v0.1.0 zeigen
```

### Falsche Version angezeigt
```bash
# Build-Cache leeren
make clean
rm -f Sources/DailyApp/AppVersion.swift

# Neue Version generieren
make version
```

### CI/CD Build-Fehler
```bash
# Manuelle Version-Generation in CI
make version || echo "Version generation failed, using fallback"
swift build  # App verwendet automatisch Fallback-Versionen
```

### Uncommitted Changes
```bash
# Status prüfen
git status

# Changes committen oder stashen
git add . && git commit -m "Fix before release"
# oder
git stash
```

## Best Practices

### 1. Release Checklist
- [ ] Alle Tests erfolgreich
- [ ] CHANGELOG.md aktualisiert
- [ ] Keine uncommitted changes
- [ ] Version in README.md aktualisiert
- [ ] App funktional getestet

### 2. Tag-Nachrichten
```bash
# Gute Tag-Nachricht
git tag -a v0.4.0 -m "Release v0.4.0

Features:
- Liquid Glass UI implementation
- Dark Mode support
- Auto-version from Git tags

Bug Fixes:
- Fixed window positioning
- Improved keyboard handling"
```

### 3. Release Notes Template
```markdown
## Daily App v0.4.0

### ✨ New Features
- Liquid Glass UI with native macOS materials
- Full Dark Mode support
- Automatic version generation from Git tags

### 🐛 Bug Fixes
- Fixed window positioning issues
- Improved keyboard event handling
- Better task list scrolling

### 🛠 Technical
- Build: 14
- Git: 4b20b90
- Date: 2025-07-13
```

## Dateien im Release-Prozess

### Automatisch generiert
- `Sources/DailyApp/AppVersion.swift` (nie committen!)

### Manuell verwaltet
- `CHANGELOG.md` - Release-Änderungen
- `README.md` - Aktuelle Version
- `Makefile` - Build-Konfiguration

### Git Ignore
```
# Generierte Dateien (bereits in .gitignore)
Sources/DailyApp/AppVersion.swift
```

---

**Wichtig**: Die `AppVersion.swift` wird automatisch generiert und sollte nie manuell bearbeitet oder committed werden!
