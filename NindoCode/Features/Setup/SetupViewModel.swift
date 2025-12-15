import Foundation
import Combine

@MainActor
final class SetupViewModel: ObservableObject {

    // MARK: Published state for the UI

    @Published var selectedSubject: String?
    @Published var selectedTopic: String?

    @Published private(set) var subjects: [String] = []
    @Published private(set) var topicsBySubject: [String: [String]] = [:]

    // MARK: Dependencies

    private let repository: QuestionRepositoryProtocol

    // MARK: Init

    init(repository: QuestionRepositoryProtocol) {
        self.repository = repository
        loadSubjectsAndTopics()
    }

    // MARK: Load data

    private func loadSubjectsAndTopics() {
        do {
            let allQuestions = try repository.fetchQuestions(filter: nil)

            // Unique subjects
            subjects = Array(Set(allQuestions.map { $0.subject }))
                .sorted()

            // Topics grouped by subject
            topicsBySubject = Dictionary(grouping: allQuestions, by: { $0.subject })
                .mapValues { questions in
                    Array(Set(questions.map { $0.topic })).sorted()
                }

        } catch {
            print("SetupViewModel error loading questions:", error)
            subjects = []
            topicsBySubject = [:]
        }
    }

    // MARK: Derived state

    var topicsForSelectedSubject: [String] {
        guard let subject = selectedSubject else { return [] }
        return topicsBySubject[subject] ?? []
    }

    var isContinueEnabled: Bool {
        selectedSubject != nil
    }

    // MARK: Filter creation

    func makeQuizFilter() -> QuizFilter {
        QuizFilter(
            subject: selectedSubject,
            topic: selectedTopic
        )
    }

    // MARK: Reset

    func resetSelection() {
        selectedSubject = nil
        selectedTopic = nil
    }
}
