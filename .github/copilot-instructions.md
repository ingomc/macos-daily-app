<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# macOS Daily App - Copilot Instructions

This is a native macOS application written in Swift using SwiftUI. The app is designed as a menu bar utility with the following characteristics:

## Project Overview
- **Language**: Swift
- **Framework**: SwiftUI + AppKit
- **Target**: macOS menu bar application
- **Architecture**: MVVM pattern

## Key Features
- Menu bar tray icon
- Global keyboard shortcut activation
- Spotlight-like popup window
- Daily task logging with text input
- Persistent data storage using UserDefaults
- Modern SwiftUI interface

## Development Guidelines
- Use SwiftUI for UI components where possible
- Integrate AppKit for menu bar functionality (NSStatusItem)
- Follow Apple's Human Interface Guidelines
- Implement proper keyboard shortcuts and accessibility
- Use UserDefaults for simple data persistence
- Maintain clean MVVM architecture

## Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names in German where appropriate
- Add proper documentation comments
- Implement error handling where necessary
