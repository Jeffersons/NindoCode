import SwiftUI

final class SetupCoordinator {

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

        SelectSubjectView(
            viewModel: viewModel,
            onSubjectSelected: {
                let filter = viewModel.makeQuizFilter()
                self.onFinish(filter)
            }
        )
    }
}
