import Foundation
import CoreData

enum QuestionsImporter {

    static func updateQuestionsIfNeeded(context: NSManagedObjectContext) {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        let decoder = JSONDecoder()
        guard let file = try? decoder.decode(QuestionsFile.self, from: data) else {
            return
        }

        let localVersion = getLocalVersion(context: context)

        if file.version > localVersion {
            importQuestions(file.questions, context: context)
            setLocalVersion(context: context, version: file.version)
        }
    }

    private static func getLocalVersion(context: NSManagedObjectContext) -> Int {
        let fetch: NSFetchRequest<VersionEntity> = VersionEntity.fetchRequest()
        fetch.fetchLimit = 1

        if let current = try? context.fetch(fetch).first {
            return Int(current.version)
        }
        return 0
    }

    private static func setLocalVersion(context: NSManagedObjectContext, version: Int) {
        let fetch: NSFetchRequest<VersionEntity> = VersionEntity.fetchRequest()
        let current = (try? context.fetch(fetch).first) ?? VersionEntity(context: context)
        current.version = Int32(version)
        try? context.save()
    }

    private static func importQuestions(_ list: [QuestionDTO], context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        if let old = try? context.fetch(fetch) {
            old.forEach { context.delete($0) }
        }

        list.forEach { item in
            let entity = QuestionEntity(context: context)
            entity.id = UUID()
            entity.text = item.text
            entity.correctIndex = Int16(item.correctIndex)
            entity.optionsData = try? JSONEncoder().encode(item.options)
            entity.subject = item.subject
            entity.topic = item.topic
        }

        try? context.save()
    }
}
