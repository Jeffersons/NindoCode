import SwiftUI

struct SetupFlowView: View {

    @ObservedObject var coordinator: SetupCoordinator
    @StateObject private var viewModel: SetupViewModel

    init(coordinator: SetupCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(
            wrappedValue: SetupViewModel(
                repository: coordinator.repository
            )
        )
    }

    var body: some View {
        switch coordinator.step {

        case .subject:
            SelectSubjectView(
                viewModel: viewModel,
                onSubjectSelected: {
                    coordinator.goToTopic()
                }
            )

        case .topic:
            SelectTopicView(
                viewModel: viewModel,
                onTopicSelected: {
                    let filter = viewModel.makeQuizFilter()
                    coordinator.onFinish(filter)
                },
                onBack: {
                    viewModel.resetSelection()
                    coordinator.goBackToSubject()
                }
            )
        }
    }
}
