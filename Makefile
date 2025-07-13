# Daily App Makefile
# Automatische Versionsgenerierung aus Git Tags

.PHONY: version build run clean release

# Version aus Git Tags extrahieren
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "0.1.0")
BUILD_NUMBER := $(shell git rev-list --count HEAD 2>/dev/null || echo "1")
GIT_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Prüfe auf uncommitted changes
DIRTY := $(shell git diff-index --quiet HEAD -- 2>/dev/null || echo "-dirty")

FULL_VERSION := $(VERSION)$(DIRTY)

version:
	@echo "Generiere Version: $(FULL_VERSION) (Build $(BUILD_NUMBER))"
	@mkdir -p Sources/DailyApp
	@echo "// Auto-generated file - DO NOT EDIT" > Sources/DailyApp/AppVersion.swift
	@echo "// Generated at $$(date)" >> Sources/DailyApp/AppVersion.swift
	@echo "" >> Sources/DailyApp/AppVersion.swift
	@echo "import Foundation" >> Sources/DailyApp/AppVersion.swift
	@echo "" >> Sources/DailyApp/AppVersion.swift
	@echo "struct AppVersion {" >> Sources/DailyApp/AppVersion.swift
	@echo "    static let version = \"$(FULL_VERSION)\"" >> Sources/DailyApp/AppVersion.swift
	@echo "    static let buildNumber = \"$(BUILD_NUMBER)\"" >> Sources/DailyApp/AppVersion.swift
	@echo "    static let gitHash = \"$(GIT_HASH)\"" >> Sources/DailyApp/AppVersion.swift
	@echo "    static let buildDate = \"$$(date -u +'%Y-%m-%d %H:%M:%S UTC')\"" >> Sources/DailyApp/AppVersion.swift
	@echo "" >> Sources/DailyApp/AppVersion.swift
	@echo "    static var fullVersion: String {" >> Sources/DailyApp/AppVersion.swift
	@echo "        return \"\\(version) (\\(buildNumber))\"" >> Sources/DailyApp/AppVersion.swift
	@echo "    }" >> Sources/DailyApp/AppVersion.swift
	@echo "" >> Sources/DailyApp/AppVersion.swift
	@echo "    static var debugInfo: String {" >> Sources/DailyApp/AppVersion.swift
	@echo "        return \"\\(version) (\\(buildNumber)) - \\(gitHash) - \\(buildDate)\"" >> Sources/DailyApp/AppVersion.swift
	@echo "    }" >> Sources/DailyApp/AppVersion.swift
	@echo "}" >> Sources/DailyApp/AppVersion.swift

build: version
	swift build

run: build
	swift run

clean:
	swift package clean
	rm -f Sources/DailyApp/AppVersion.swift

release: version
	swift build -c release

# Erstelle einen neuen Tag
tag:
	@echo "Aktuelle Tags:"
	@git tag -l | sort -V
	@echo ""
	@read -p "Neue Version (z.B. v0.4.0): " VERSION; \
	git tag $$VERSION && \
	echo "Tag $$VERSION erstellt. Verwende 'git push origin --tags' zum Pushen."

install: release
	cp .build/release/DailyApp /usr/local/bin/daily-app
