import SwiftUI

struct SetupFlowView: View {

    @ObservedObject var coordinator: SetupCoordinator
    @StateObject private var viewModel: SetupViewModel

    init(coordinator: SetupCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(
            wrappedValue: SetupViewModel(
                repository: coordinator.quizRepository
            )
        )
    }

    var body: some View {
        switch coordinator.step {

        case .subject:
            SelectSubjectView(
                viewModel: viewModel,
                onSubjectSelected: {
                    coordinator.goToTopics()
                }
            )

        case .topic:
            SelectTopicView(
                viewModel: viewModel,
                onTopicSelected: {
                    coordinator.goToOptions()
                },
                onBack: {
                    coordinator.goBackToSubject(viewModel: viewModel)
                }
            )

        case .options:
            QuizOptionsView(
                viewModel: viewModel,
                onStartQuiz: {
                    let filter = viewModel.makeQuizFilter()
                    coordinator.finishSetup(with: filter)
                },
                onBack: {
                    coordinator.goBackToTopic(viewModel: viewModel)
                }
            )
        }
    }
}
