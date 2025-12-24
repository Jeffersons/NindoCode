import Combine
import CoreData

@MainActor
final class QuizViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published var selectedIndex: Int?
    @Published private(set) var isAnswered: Bool = false
    @Published private(set) var showFinished: Bool = false

    // MARK: - Dependencies

    private let repository: QuestionRepositoryProtocol
    private let filter: QuizFilter?

    // MARK: - Data

    private var questions: [Question] = []

    // MARK: - Scoring

    private let pointsRight = 10
    private let pointsWrong = 5

    // MARK: - Init
    
    let onExit: () -> Void

    init(
        repository: QuestionRepositoryProtocol,
        filter: QuizFilter?,
        onExit: @escaping () -> Void
    ) {
        self.repository = repository
        self.filter = filter
        self.onExit = onExit
        loadQuestions()
    }
    
    // MARK: Title

    var title: String {
        if let subject = filter?.subject {
            return "Quiz \(subject)"
        }
        return "Quiz"
    }
    
    var answeredCount: Int {
        currentIndex
    }

    var remainingCount: Int {
        totalQuestions - currentIndex
    }

    // MARK: - Load

    func loadQuestions() {
        do {
            let fetched = try repository.fetchQuestions(filter: filter)
            questions = fetched.shuffled()

            resetState()
            showFinished = questions.isEmpty

        } catch {
            print("QuizViewModel fetch error:", error)
            questions = []
            showFinished = true
        }
    }
    
    func quitQuiz() {
        onExit()
    }

    private func resetState() {
        currentIndex = 0
        score = 0
        selectedIndex = nil
        isAnswered = false
    }

    // MARK: - Accessors

    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int {
        questions.count
    }

    // MARK: - Actions

    func selectOption(_ index: Int) {
        guard !isAnswered else { return }
        selectedIndex = index
    }

    func confirmAnswer() {
        guard let question = currentQuestion,
              let selected = selectedIndex,
              !isAnswered else { return }

        isAnswered = true

        if selected == question.correctIndex {
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
    
    func dismissFinishedAlert() {
        showFinished = false
    }

    func restart() {
        loadQuestions()
    }
}
