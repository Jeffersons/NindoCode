import Foundation

struct QuestionsFile: Codable {
    let subject: String
    let version: Int
    let questions: [QuestionDTO]
}

struct QuestionDTO: Codable {
    let topic: String
    let text: String
    let options: [String]
    let correctIndex: Int
}
