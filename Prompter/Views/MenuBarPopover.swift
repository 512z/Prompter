import SwiftUI
import UserNotifications

struct MenuBarPopover: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var settings = SettingsManager()
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showingEditor = false
    @State private var editingPrompt: Prompt?
    @State private var showingSettings = false

    var filteredPrompts: [Prompt] {
        let categoryFiltered = selectedCategory == nil ? dataManager.prompts : dataManager.prompts.filter { $0.category == selectedCategory }

        if searchText.isEmpty {
            return categoryFiltered
        }
        return categoryFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with search
            VStack(spacing: 8) {
                HStack {
                    Text("Prompter")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingEditor = true; editingPrompt = nil }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .help("Add new prompt")

                    Menu {
                        Button("Settings") { showingSettings = true }
                        Divider()
                        Button("Export Prompts") { exportPrompts() }
                        Button("Import Prompts") { importPrompts() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 20)
                }

                TextField("Search prompts...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()

            Divider()

            // Category selector
            if !dataManager.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(dataManager.categories, id: \.self) { category in
                            CategoryChip(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                Divider()
            }

            // Prompt list
            if filteredPrompts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No prompts yet" : "No matching prompts")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredPrompts) { prompt in
                        PromptRow(prompt: prompt, onEdit: {
                            editingPrompt = prompt
                            showingEditor = true
                        }, onDelete: {
                            dataManager.deletePrompt(prompt)
                        })
                    }
                }
                .listStyle(.plain)
            }

            Divider()

            // Footer
            HStack {
                Text("\(filteredPrompts.count) prompt\(filteredPrompts.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 360, height: 500)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditor) {
            PromptEditorView(dataManager: dataManager, settings: settings, prompt: editingPrompt)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
    }

    func exportPrompts() {
        guard let data = dataManager.exportPrompts() else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "prompts.json"

        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? data.write(to: url)
        }
    }

    func importPrompts() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            if let data = try? Data(contentsOf: url) {
                try? dataManager.importPrompts(from: data)
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct PromptRow: View {
    let prompt: Prompt
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.title)
                    .font(.headline)
                Text(prompt.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text(prompt.category)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }

            Spacer()

            HStack(spacing: 4) {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(prompt.content, forType: .string)
                    showCopiedNotification()
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Edit")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete")
            }
        }
        .padding(.vertical, 4)
    }

    func showCopiedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Copied!"
        content.body = prompt.title

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
