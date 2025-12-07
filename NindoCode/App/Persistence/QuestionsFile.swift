import Foundation

struct QuestionsFile: Codable {
    let version: Int
    let questions: [QuestionDTO]
}

struct QuestionDTO: Codable {
    let subject: String
    let topic: String
    let text: String
    let options: [String]
    let correctIndex: Int
}
