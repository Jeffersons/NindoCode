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
    let onExit: () -> Void

    // MARK: - Data

    private var questions: [QuizQuestion] = []

    // MARK: - Scoring

    private let pointsRight = 10
    private let pointsWrong = 5

    // MARK: - Init

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

    // MARK: - Title

    var title: String {
        if let subject = filter?.subject {
            return "Quiz \(subject)"
        }
        return "Quiz"
    }

    // MARK: - Progress

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
            let limited = applyLimitIfNeeded(fetched)
            questions = buildQuizQuestions(from: limited)
            
            print(
                "IDs:",
                fetched.map { $0.id }
            )

            resetState()
            showFinished = questions.isEmpty

        } catch {
            print("QuizViewModel fetch error:", error)
            questions = []
            showFinished = true
        }
    }

    private func applyLimitIfNeeded(_ questions: [Question]) -> [Question] {
        guard let limit = filter?.numberOfQuestions else {
            return questions.shuffled()
        }
        return Array(questions.shuffled().prefix(limit))
    }

    private func buildQuizQuestions(from questions: [Question]) -> [QuizQuestion] {
        questions.map { question in
            let correctAnswer = question.options[question.correctIndex]
            let shuffledOptions = question.options.shuffled()
            let newCorrectIndex = shuffledOptions.firstIndex(of: correctAnswer)!

            return QuizQuestion(
                text: question.text,
                options: shuffledOptions,
                correctIndex: newCorrectIndex
            )
        }
    }

    private func resetState() {
        currentIndex = 0
        score = 0
        selectedIndex = nil
        isAnswered = false
    }

    // MARK: - Navigation

    func quitQuiz() {
        onExit()
    }

    func dismissFinishedAlert() {
        showFinished = false
    }

    func restart() {
        loadQuestions()
    }

    // MARK: - Accessors

    var currentQuestion: QuizQuestion? {
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
}
