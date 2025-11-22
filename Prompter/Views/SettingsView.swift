import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss

    @State private var apiKeyInput: String

    init(settings: SettingsManager) {
        self.settings = settings
        _apiKeyInput = State(initialValue: settings.geminiApiKey)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                // AI Enhancement Toggle
                Toggle(isOn: $settings.aiEnhancementEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Enhancement")
                            .font(.body)
                        Text("Optimize prompts using Gemini API")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if settings.aiEnhancementEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gemini API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        SecureField("Enter your API key", text: $apiKeyInput)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.caption)

                            Link("Get API key from Google AI Studio", destination: URL(string: "https://aistudio.google.com/apikey")!)
                                .font(.caption)
                        }

                        if !apiKeyInput.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("API key configured")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 8)
                }
            }

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Save") {
                    settings.geminiApiKey = apiKeyInput
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
        }
        .padding()
        .frame(width: 450, height: 300)
    }
}
