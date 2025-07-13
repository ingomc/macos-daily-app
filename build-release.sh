#!/bin/bash

# Daily App Build & Release Script
set -e

echo "🚀 Building Daily App for Release..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf "Daily App.app"
rm -f Daily-App.dmg
rm -f Daily-App.zip

# Build Release
echo "🔨 Building Swift Package..."
swift build -c release

# Create App Bundle
echo "📦 Creating App Bundle..."
mkdir -p "Daily App.app/Contents/MacOS"
mkdir -p "Daily App.app/Contents/Resources"

# Copy binary
cp .build/release/DailyApp "Daily App.app/Contents/MacOS/Daily App"
chmod +x "Daily App.app/Contents/MacOS/Daily App"

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "Daily App.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Daily App</string>
    <key>CFBundleIdentifier</key>
    <string>com.andre.dailyapp</string>
    <key>CFBundleName</key>
    <string>Daily App</string>
    <key>CFBundleDisplayName</key>
    <string>Daily App</string>
    <key>CFBundleVersion</key>
    <string>0.2</string>
    <key>CFBundleShortVersionString</key>
    <string>0.2.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
EOF

# Optional: Code signing (nur wenn Developer Certificate vorhanden)
if security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "✍️ Code signing..."
    codesign --force --deep --sign - "Daily App.app"
else
    echo "⚠️ No code signing certificate found, skipping..."
fi

# Create ZIP
echo "🗜️ Creating ZIP archive..."
zip -r "Daily-App.zip" "Daily App.app"

# Create DMG (optional, requires more tools)
if command -v hdiutil &> /dev/null; then
    echo "💿 Creating DMG..."
    mkdir dmg-temp
    cp -R "Daily App.app" dmg-temp/
    hdiutil create -volname "Daily App" -srcfolder dmg-temp -ov -format UDZO "Daily-App.dmg"
    rm -rf dmg-temp
    echo "✅ Created Daily-App.dmg"
fi

echo ""
echo "🎉 Build Complete!"
echo "📁 Files created:"
echo "   - Daily App.app (App Bundle)"
echo "   - Daily-App.zip (Portable Archive)"
if [ -f "Daily-App.dmg" ]; then
    echo "   - Daily-App.dmg (Installer)"
fi
echo ""
echo "🚀 Ready for distribution!"
