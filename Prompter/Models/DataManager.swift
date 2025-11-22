import Foundation

class DataManager: ObservableObject {
    @Published var prompts: [Prompt] = []

    private let fileURL: URL

    init() {
        // Get Application Support directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("Prompter", isDirectory: true)

        // Create directory if needed
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)

        fileURL = appDirectory.appendingPathComponent("prompts.json")
        loadPrompts()
    }

    var categories: [String] {
        let uniqueCategories = Set(prompts.map { $0.category })
        return uniqueCategories.sorted()
    }

    func loadPrompts() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Initialize with sample data
            prompts = [
                Prompt(title: "Code Reviewer", content: "You are an expert code reviewer. Review the following code for bugs, performance issues, and best practices.", category: "Coding"),
                Prompt(title: "Writing Assistant", content: "You are a professional writing assistant. Help me improve the clarity and flow of my writing.", category: "Writing")
            ]
            savePrompts()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            prompts = try JSONDecoder().decode([Prompt].self, from: data)
        } catch {
            print("Error loading prompts: \(error)")
            prompts = []
        }
    }

    func savePrompts() {
        do {
            let data = try JSONEncoder().encode(prompts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving prompts: \(error)")
        }
    }

    func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt)
        savePrompts()
    }

    func updatePrompt(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            savePrompts()
        }
    }

    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        savePrompts()
    }

    func exportPrompts() -> Data? {
        try? JSONEncoder().encode(prompts)
    }

    func importPrompts(from data: Data) throws {
        let importedPrompts = try JSONDecoder().decode([Prompt].self, from: data)
        prompts.append(contentsOf: importedPrompts)
        savePrompts()
    }
}
