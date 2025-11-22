import Foundation

class SettingsManager: ObservableObject {
    @Published var aiEnhancementEnabled: Bool {
        didSet {
            UserDefaults.standard.set(aiEnhancementEnabled, forKey: "aiEnhancementEnabled")
        }
    }

    @Published var geminiApiKey: String {
        didSet {
            UserDefaults.standard.set(geminiApiKey, forKey: "geminiApiKey")
        }
    }

    init() {
        self.aiEnhancementEnabled = UserDefaults.standard.bool(forKey: "aiEnhancementEnabled")
        self.geminiApiKey = UserDefaults.standard.string(forKey: "geminiApiKey") ?? ""
    }

    var isConfigured: Bool {
        aiEnhancementEnabled && !geminiApiKey.isEmpty
    }
}
