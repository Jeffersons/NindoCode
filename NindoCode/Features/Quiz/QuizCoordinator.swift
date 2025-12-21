import SwiftUI
import CoreData

final class QuizCoordinator {

    private let context: NSManagedObjectContext
    private let filter: QuizFilter
    private let onFinish: () -> Void

    init(
        context: NSManagedObjectContext,
        filter: QuizFilter,
        onFinish: @escaping () -> Void
    ) {
        self.context = context
        self.filter = filter
        self.onFinish = onFinish
    }

    @ViewBuilder
    func start() -> some View {
        let repository = QuestionRepository(context: context)
        let viewModel = QuizViewModel(
            repository: repository,
            filter: filter,
            onExit: {
                self.onFinish()
            }
        )

        QuizView(viewModel: viewModel)
    }
}
