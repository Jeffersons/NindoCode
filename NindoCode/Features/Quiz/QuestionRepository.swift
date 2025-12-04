import CoreData

protocol QuestionRepositoryProtocol {
    func fetchQuestions() throws -> [Question]
}

final class QuestionRepository: QuestionRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchQuestions() throws -> [Question] {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()

        let entities = try context.fetch(request)

        return entities.map { entity in
            Question(
                id: entity.safeId,
                text: entity.safeText,
                options: entity.options,
                correctIndex: Int(entity.correctIndex)
            )
        }
    }
}
