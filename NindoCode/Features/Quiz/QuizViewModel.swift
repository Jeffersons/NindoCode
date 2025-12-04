import Combine
import CoreData

@MainActor
final class QuizViewModel: ObservableObject {

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published var selectedIndex: Int? = nil
    @Published private(set) var isAnswered: Bool = false
    @Published var showFinished: Bool = false

    private let repository: QuestionRepositoryProtocol
    private var questions: [Question] = []

    private let pointsRight = 10
    private let pointsWrong = 5

    init(repository: QuestionRepositoryProtocol) {
        self.repository = repository
        loadQuestions()
    }

    func loadQuestions() {
        do {
            let fetched = try repository.fetchQuestions()
            questions = fetched.shuffled()

            currentIndex = 0
            score = 0
            selectedIndex = nil
            isAnswered = false
            showFinished = questions.isEmpty

        } catch {
            print("Fetch error: \(error)")
            questions = []
            showFinished = true
        }
    }

    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int {
        questions.count
    }

    func selectOption(_ index: Int) {
        guard !isAnswered else { return }
        selectedIndex = index
    }

    func confirmAnswer() {
        guard let q = currentQuestion,
              let selected = selectedIndex,
              !isAnswered else { return }

        isAnswered = true

        if selected == q.correctIndex {
            score += pointsRight
        } else {
            score = max(0, score - pointsWrong)
        }
    }

    func nextQuestion() {
        guard isAnswered else { return }

        selectedIndex = nil
        isAnswered = false
        currentIndex += 1

        if currentIndex >= questions.count {
            showFinished = true
        }
    }

    func restart() {
        loadQuestions()
    }
}
