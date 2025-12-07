import CoreData

extension QuestionEntity {

    var safeId: UUID { id ?? UUID() }
    var safeText: String { text ?? "" }
    var safeSubject: String { subject ?? "" }
    var safeTopic: String { topic ?? "" }

    var options: [String] {
        guard let data = optionsData else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
