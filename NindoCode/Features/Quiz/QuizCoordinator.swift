import SwiftUI
import CoreData

final class QuizCoordinator {

    private let context: NSManagedObjectContext
    private let filter: QuizFilter

    init(
        context: NSManagedObjectContext,
        filter: QuizFilter
    ) {
        self.context = context
        self.filter = filter
    }

    @ViewBuilder
    func start() -> some View {
        let repository = QuestionRepository(context: context)
        let viewModel = QuizViewModel(
            repository: repository,
            filter: filter
        )

        QuizView(viewModel: viewModel)
    }
}
