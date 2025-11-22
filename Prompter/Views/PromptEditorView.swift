import SwiftUI

struct PromptEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager: DataManager
    @ObservedObject var settings: SettingsManager

    let prompt: Prompt?

    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var showingNewCategory = false
    @State private var newCategoryName = ""
    @State private var isOptimizing = false
    @State private var errorMessage: String?

    init(dataManager: DataManager, settings: SettingsManager, prompt: Prompt?) {
        self.dataManager = dataManager
        self.settings = settings
        self.prompt = prompt
        _title = State(initialValue: prompt?.title ?? "")
        _content = State(initialValue: prompt?.content ?? "")
        _category = State(initialValue: prompt?.category ?? "")
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty &&
        !category.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(prompt == nil ? "New Prompt" : "Edit Prompt")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 4) {
                Text("Category")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    if dataManager.categories.isEmpty || showingNewCategory {
                        TextField("Category name", text: $category)
                            .textFieldStyle(.roundedBorder)
                        if !dataManager.categories.isEmpty {
                            Button("Cancel") {
                                showingNewCategory = false
                                category = ""
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Picker("Category", selection: $category) {
                            Text("Select category").tag("")
                            ForEach(dataManager.categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .labelsHidden()

                        Button(action: { showingNewCategory = true; category = "" }) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(.plain)
                        .help("New category")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Content")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if settings.isConfigured {
                        Button(action: optimizePrompt) {
                            HStack(spacing: 4) {
                                if isOptimizing {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 12, height: 12)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.caption)
                                }
                                Text(isOptimizing ? "Optimizing..." : "AI Optimize")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(content.isEmpty || isOptimizing)
                        .help("Optimize this prompt using AI")
                    }
                }

                TextEditor(text: $content)
                    .font(.body)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.2))

                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button(prompt == nil ? "Add" : "Save") {
                    savePrompt()
                }
                .keyboardShortcut(.return)
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 400)
    }

    func savePrompt() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedContent = content.trimmingCharacters(in: .whitespaces)
        let trimmedCategory = category.trimmingCharacters(in: .whitespaces)

        if let existingPrompt = prompt {
            let updated = Prompt(
                id: existingPrompt.id,
                title: trimmedTitle,
                content: trimmedContent,
                category: trimmedCategory,
                dateCreated: existingPrompt.dateCreated
            )
            dataManager.updatePrompt(updated)
        } else {
            let newPrompt = Prompt(
                title: trimmedTitle,
                content: trimmedContent,
                category: trimmedCategory
            )
            dataManager.addPrompt(newPrompt)
        }

        dismiss()
    }

    func optimizePrompt() {
        guard !content.isEmpty else { return }

        isOptimizing = true
        errorMessage = nil

        Task {
            do {
                let optimized = try await GeminiService.shared.optimizePrompt(
                    originalPrompt: content,
                    apiKey: settings.geminiApiKey
                )

                await MainActor.run {
                    content = optimized
                    isOptimizing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isOptimizing = false
                }
            }
        }
    }
}
