import SwiftUI
import Combine

@MainActor
final class SetupCoordinator: ObservableObject {

    enum Step {
        case subject
        case topic
    }

    @Published var step: Step = .subject

    let repository: QuestionRepositoryProtocol
    let onFinish: (QuizFilter) -> Void

    init(
        repository: QuestionRepositoryProtocol,
        onFinish: @escaping (QuizFilter) -> Void
    ) {
        self.repository = repository
        self.onFinish = onFinish
    }

    func goToTopic() {
        step = .topic
    }

    func goBackToSubject() {
        step = .subject
    }
}
