#!/bin/bash

# Script um automatisch die Version aus Git Tags zu extrahieren
# und in eine Swift Datei zu schreiben

# Git Tag holen (neuester Tag)
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.1.0")

# Falls kein Tag existiert, fallback
if [ -z "$VERSION" ]; then
    VERSION="0.1.0-dev"
fi

# Build Number aus Git Commit Count
BUILD_NUMBER=$(git rev-list --count HEAD 2>/dev/null || echo "1")

# Git Hash für Debug Info
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Prüfe ob es uncommitted changes gibt
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    VERSION="${VERSION}-dirty"
fi

# Swift Datei generieren
cat > Sources/DailyApp/AppVersion.swift << EOF
// Auto-generated file - DO NOT EDIT
// Generated at $(date)

import Foundation

struct AppVersion {
    static let version = "$VERSION"
    static let buildNumber = "$BUILD_NUMBER"
    static let gitHash = "$GIT_HASH"
    static let buildDate = "$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    
    static var fullVersion: String {
        return "\(version) (\(buildNumber))"
    }
    
    static var debugInfo: String {
        return "\(version) (\(buildNumber)) - \(gitHash) - \(buildDate)"
    }
}
EOF

echo "Version generated: $VERSION (Build $BUILD_NUMBER)"
