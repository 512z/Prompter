# Prompter

<p align="center">
  <img src="example.png" alt="Prompter Screenshot" width="600">
</p>

<p align="center">
  <strong>A lightweight macOS menu bar app for managing and quickly accessing your AI prompts and roles.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
</p>

---

## ✨ Features

- 🎯 **Menu Bar Integration** - Quick access from the macOS menu bar
- 📁 **Category Organization** - Organize prompts by categories (Coding, Writing, Research, etc.)
- 🔍 **Quick Search** - Filter prompts by title or content
- 📋 **One-Click Copy** - Copy prompts to clipboard with a single click
- ✏️ **CRUD Operations** - Create, read, update, and delete prompts
- 💾 **Import/Export** - Backup and share your prompts as JSON
- ⌨️ **Global Hotkey** - Press `Cmd+Shift+P` to toggle the app from anywhere
- 💿 **Persistent Storage** - Prompts saved automatically to disk

## 📦 Installation

### Option 1: Download Pre-built App
1. Download the latest release from [Releases](https://github.com/512z/Prompter/releases)
2. Unzip and move `Prompter.app` to `/Applications`
3. Right-click and select "Open" (first time only)

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/512z/Prompter.git
cd Prompter

# Open in Xcode
open Prompter.xcodeproj

# Build and run (Cmd+R)
```

**Requirements:**
- macOS 13.0 or later
- Xcode 15.0 or later (for building from source)

## 🚀 Quick Start

### First Launch
1. Click the menu bar icon (💬 speech bubble) to open the app
2. Two sample prompts are included to get you started

### Adding Prompts
1. Click the **`+`** button in the header
2. Fill in:
   - **Title**: Short name for the prompt
   - **Category**: Select existing or create new
   - **Content**: The actual prompt text
3. Click **"Add"** or press `Enter`

### Using Prompts
- **Browse**: Select a category chip to filter prompts
- **Search**: Type in the search bar to find prompts
- **Copy**: Click the 📄 icon to copy prompt to clipboard
- **Edit**: Click the ✏️ icon to modify a prompt
- **Delete**: Click the 🗑️ icon to remove a prompt

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+P` | Toggle app visibility from anywhere |
| `Enter` | Save prompt in editor |
| `Escape` | Cancel editing |

> **Note:** For the global hotkey to work, grant Accessibility permissions in **System Settings → Privacy & Security → Accessibility**.

## 💾 Import/Export

1. Click the **`⋯`** menu in the header
2. **Export Prompts**: Save all prompts to a JSON file
3. **Import Prompts**: Load prompts from a JSON file

Share your prompt collections with team members or backup your prompts!

## 🏗️ Project Structure

```
Prompter/
├── PrompterApp.swift          # Main app + menu bar setup
├── Models/
│   ├── Prompt.swift           # Data model
│   └── DataManager.swift      # Persistence layer (JSON)
├── Views/
│   ├── MenuBarPopover.swift   # Main dropdown UI
│   └── PromptEditorView.swift # Add/edit prompt form
└── Utils/
    └── HotKeyManager.swift    # Global hotkey registration
```

## 📂 Data Storage

Prompts are stored in:
```
~/Library/Application Support/Prompter/prompts.json
```

## 🛠️ Development

Built with **SwiftUI** following the "bacterial coding" philosophy:
- **Small**: Minimal, focused functions
- **Modular**: Independent, swappable components
- **Self-contained**: Easy to copy and reuse

### Building

```bash
# Build from command line
xcodebuild -scheme Prompter -configuration Release

# Run the app
open ~/Library/Developer/Xcode/DerivedData/Prompter-*/Build/Products/Release/Prompter.app
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 💡 Tips

- Use descriptive titles for easy searching
- Create categories that match your workflow
- Export your prompts regularly for backup
- Share prompt collections with team members via export/import

## 🐛 Troubleshooting

**Menu bar icon not appearing:**
- Ensure the app is running (check Activity Monitor)
- Restart the app

**Hotkey not working:**
- Grant Accessibility permissions in **System Settings → Privacy & Security → Accessibility**

**Prompts not saving:**
- Check disk permissions for Application Support folder
- Ensure the app isn't running in multiple instances

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with SwiftUI and ❤️ for the AI community.

---

<p align="center">
  Made with 💬 by <a href="https://github.com/512z">@512z</a>
</p>
