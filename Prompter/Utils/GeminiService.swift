import Foundation

class GeminiService {
    static let shared = GeminiService()

    private init() {}

    func optimizePrompt(originalPrompt: String, apiKey: String) async throws -> String {
        let systemPrompt = """
        You are a professional prompt engineer. Your task is to enhance and optimize prompts for AI interactions.

        Please improve the following prompt by:
        - Making it more clear and specific
        - Adding better structure and formatting
        - Including relevant context or constraints
        - Ensuring it will produce better AI responses

        Keep the core intent of the original prompt but make it significantly better.

        Original prompt:
        """

        let fullPrompt = systemPrompt + "\n\n" + originalPrompt

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": fullPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 2048
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw GeminiError.apiError(statusCode: httpResponse.statusCode)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let candidates = json?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.parseError
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum GeminiError: LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .apiError(let code):
            return "API error (status code: \(code)). Please check your API key."
        case .parseError:
            return "Failed to parse response from Gemini API"
        }
    }
}
