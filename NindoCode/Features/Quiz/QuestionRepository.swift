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

        let questions = entities.map {
            Question(
                id: $0.safeId,
                text: $0.safeText,
                options: $0.options,
                correctIndex: Int($0.correctIndex),
                subject: $0.safeSubject,
                topic: $0.safeTopic
            )
        }

        return Array(questions.shuffled().prefix(filter?.numberOfQuestions ?? 10))
    }
}
