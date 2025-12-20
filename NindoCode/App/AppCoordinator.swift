import SwiftUI
import Combine
import CoreData

final class AppCoordinator: ObservableObject {

    enum Route {
        case setup
        case quiz(QuizFilter)
    }

    @Published private(set) var route: Route = .setup

    private let persistence: PersistenceController

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func startQuiz(with filter: QuizFilter) {
        route = .quiz(filter)
    }

    @ViewBuilder
    func start() -> some View {
        let context = persistence.container.viewContext
        let repository = QuestionRepository(context: context)

        switch route {
        case .setup:
            let setupCoordinator = SetupCoordinator(
                repository: repository
            ) { filter in
                self.startQuiz(with: filter)
            }

            SetupFlowView(coordinator: setupCoordinator)

        case .quiz(let filter):
            QuizCoordinator(
                context: context,
                filter: filter
            )
            .start()
        }
    }
}
