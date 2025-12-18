import CoreData

protocol QuestionRepositoryProtocol {
    func fetchQuestions(filter: QuizFilter?) throws -> [Question]
}

final class PreviewQuestionRepository: QuestionRepositoryProtocol {
    func fetchQuestions(filter: QuizFilter?) throws -> [Question] {
        []
    }
}

final class QuestionRepository: QuestionRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.context = context
    }

    func fetchQuestions(filter: QuizFilter?) throws -> [Question] {

        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()

        if let filter = filter {
            var predicates: [NSPredicate] = []

            if let subject = filter.subject {
                predicates.append(
                    NSPredicate(format: "subject == %@", subject)
                )
            }

            if let topic = filter.topic {
                predicates.append(
                    NSPredicate(format: "topic == %@", topic)
                )
            }

            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: predicates
                )
            }
        }

        let entities = try context.fetch(request)

        return entities.map { entity in
            Question(
                id: entity.safeId,
                text: entity.safeText,
                options: entity.options,
                correctIndex: Int(entity.correctIndex),
                subject: entity.safeSubject,
                topic: entity.safeTopic
            )
        }
    }
}
