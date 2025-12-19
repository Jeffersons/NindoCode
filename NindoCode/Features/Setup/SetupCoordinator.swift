import SwiftUI

final class SetupCoordinator {
    
    enum Step {
        case subject
        case topic
    }

    @State private var step: Step = .subject

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
        let viewModel = SetupViewModel(repository: repository)

        switch step {
        case .subject:
            SelectSubjectView(
                viewModel: viewModel,
                onSubjectSelected: {
                    self.step = .topic
                }
            )

        case .topic:
            SelectTopicView(
                viewModel: viewModel,
                onTopicSelected: {
                },
                onBack: {
                    viewModel.resetSelection()
                    self.step = .subject
                }
            )
        }
    }
}
