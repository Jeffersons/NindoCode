import SwiftUI
import Combine

@MainActor
final class SetupCoordinator: ObservableObject {

    enum Step {
        case subject
        case topic
        case options
    }

    @Published var step: Step = .subject

    private let repository: QuestionRepositoryProtocol
    private let onFinish: (QuizFilter) -> Void

    init(
        repository: QuestionRepositoryProtocol,
        onFinish: @escaping (QuizFilter) -> Void
    ) {
        self.repository = repository
        self.onFinish = onFinish
    }

    @ViewBuilder
    func start() -> some View {
        SetupFlowView(coordinator: self)
    }

    // MARK: - Navigation actions

    func goToTopics() {
        step = .topic
    }

    func goToOptions() {
        step = .options
    }

    func goBackToSubject(viewModel: SetupViewModel) {
        viewModel.resetSelection()
        step = .subject
    }

    func goBackToTopic(viewModel: SetupViewModel) {
        viewModel.selectedTopic = nil
        step = .topic
    }

    func finishSetup(with filter: QuizFilter) {
        onFinish(filter)
    }

    // Expose repository internally
    var quizRepository: QuestionRepositoryProtocol {
        repository
    }
}
