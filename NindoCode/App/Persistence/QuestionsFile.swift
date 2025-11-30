import Foundation

struct QuestionsFile: Codable {
    let version: Int
    let questions: [QuestionDTO]
}

struct QuestionDTO: Codable {
    let text: String
    let options: [String]
    let correctIndex: Int
}
