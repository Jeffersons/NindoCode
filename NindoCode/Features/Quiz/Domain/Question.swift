import Foundation

struct Question: Identifiable, Equatable {
    let id: UUID
    let text: String
    let options: [String]
    let correctIndex: Int
    let subject: String
    let topic: String
}
