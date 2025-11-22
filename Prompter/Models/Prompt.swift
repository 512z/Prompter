import Foundation

struct Prompt: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var category: String
    var dateCreated: Date

    init(id: UUID = UUID(), title: String, content: String, category: String, dateCreated: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.dateCreated = dateCreated
    }
}
