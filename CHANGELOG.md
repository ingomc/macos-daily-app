# Changelog

All notable changes to Daily App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-07-13

### ✨ Added
- **Dual View Modes**: Compact and Extended view with smooth toggle animation
  - Compact view: Shows max 10 tasks in single-line format
  - Extended view: Groups tasks by date with full details
- **Date Grouping**: Tasks are automatically grouped by day in extended view
  - "Heute" (Today), "Gestern" (Yesterday), or full date format
  - Task count display per day
- **Bulk Delete**: Delete entire days worth of tasks with one click
- **Enhanced Task Display**: 
  - Compact format: "Task text ... Heute • 14:30"
  - Extended format: Full date and time information
- **Apple Intelligence-style UI**:
  - Animated gradient borders on focused input field
  - Angular gradient animation (blue → purple → cyan → blue)
  - Enhanced symbol effects and animations

### 🎨 Improved
- **Liquid Glass Design**: Enhanced glassmorphism with multiple gradient overlays
- **Task Animations**: 
  - "Fly-out" animation when creating new tasks (Messages app style)
  - Smooth transitions between compact/extended views
  - Enhanced hover and focus states
- **Typography & Layout**:
  - Optimized spacing and font sizes for both view modes
  - Better visual hierarchy with consistent styling
  - Improved empty state messaging

### 🔧 Fixed
- Empty state placeholder height causing unwanted scrollbar
- SwiftUI compiler complexity issues resolved through view decomposition
- FocusState binding syntax corrections
- Type-safe gradient implementation with AnyShapeStyle

### 📋 Technical
- Requires macOS 15.0+ (Sequoia/Tahoe)
- Modern SwiftUI implementation with latest APIs
- MVVM architecture with proper state management
- UserDefaults persistence for task storage

## [0.1.0] - 2025-07-13

### 🎉 Initial Release
- **Core Functionality**:
  - Add daily tasks with text input
  - Delete individual tasks on hover
  - Persistent storage with UserDefaults
- **macOS Integration**:
  - Menu bar application (no dock icon)
  - Global keyboard shortcut: `Cmd+Shift+D`
  - Context menu with app controls
- **Modern Design**:
  - Liquid glass morphism background
  - Gradient icons and smooth animations
  - Dark mode optimized appearance
- **User Experience**:
  - Spotlight-like popup interface
  - Auto-focus on text input
  - Real-time task counter
  - Current date display

---

### Version Format
- **Major** (X.0.0): Breaking changes or major feature overhauls
- **Minor** (0.X.0): New features, enhancements, significant improvements
- **Patch** (0.0.X): Bug fixes, small improvements, maintenance

### Icons Legend
- ✨ New features
- 🎨 UI/UX improvements  
- 🔧 Bug fixes
- 📋 Technical/Documentation
- 🎉 Major milestones
