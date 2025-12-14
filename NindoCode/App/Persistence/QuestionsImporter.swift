import Foundation
import CoreData

enum QuestionsImporter {

    static func updateQuestionsIfNeeded(context: NSManagedObjectContext) {
        let fileNames = loadQuestionFileNames()

        for fileName in fileNames {
            importIfNeeded(
                fileName: fileName,
                context: context
            )
        }
    }

    // MARK: - Private

    private static func loadQuestionFileNames() -> [String] {
        guard let urls = Bundle.main.urls(
            forResourcesWithExtension: "json",
            subdirectory: "Questions"
        ) else {
            return []
        }

        return urls.map {
            $0.deletingPathExtension().lastPathComponent
        }
    }

    private static func importIfNeeded(
        fileName: String,
        context: NSManagedObjectContext
    ) {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "json",
            subdirectory: "Questions"
        ),
        let data = try? Data(contentsOf: url)
        else {
            return
        }

        let decoder = JSONDecoder()

        guard let file = try? decoder.decode(QuestionsFile.self, from: data) else {
            return
        }

        let localVersion = getLocalVersion(
            subject: file.subject,
            context: context
        )

        guard file.version > localVersion else {
            return
        }

        importQuestions(
            file.questions,
            subject: file.subject,
            context: context
        )

        setLocalVersion(
            subject: file.subject,
            version: file.version,
            context: context
        )
    }

    private static func getLocalVersion(
        subject: String,
        context: NSManagedObjectContext
    ) -> Int {
        let fetch: NSFetchRequest<VersionEntity> = VersionEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "subject == %@", subject)
        fetch.fetchLimit = 1

        if let current = try? context.fetch(fetch).first {
            return Int(current.version)
        }

        return 0
    }

    private static func setLocalVersion(
        subject: String,
        version: Int,
        context: NSManagedObjectContext
    ) {
        let fetch: NSFetchRequest<VersionEntity> = VersionEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "subject == %@", subject)
        fetch.fetchLimit = 1

        let entity = (try? context.fetch(fetch).first)
            ?? VersionEntity(context: context)

        entity.subject = subject
        entity.version = Int32(version)

        try? context.save()
    }

    private static func importQuestions(
        _ list: [QuestionDTO],
        subject: String,
        context: NSManagedObjectContext
    ) {
        let fetch: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "subject == %@", subject)

        if let old = try? context.fetch(fetch) {
            old.forEach { context.delete($0) }
        }

        list.forEach { item in
            let entity = QuestionEntity(context: context)
            entity.id = UUID()
            entity.text = item.text
            entity.correctIndex = Int16(item.correctIndex)
            entity.optionsData = try? JSONEncoder().encode(item.options)
            entity.subject = subject
            entity.topic = item.topic
        }

        try? context.save()
    }
}
