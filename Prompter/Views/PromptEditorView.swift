import SwiftUI

struct PromptEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager: DataManager

    let prompt: Prompt?

    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var showingNewCategory = false
    @State private var newCategoryName = ""

    init(dataManager: DataManager, prompt: Prompt?) {
        self.dataManager = dataManager
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
                Text("Content")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $content)
                    .font(.body)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.2))
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
}
