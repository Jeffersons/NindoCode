import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = CoreDataModelBuilder.makeModel()
        container = NSPersistentContainer(name: "NindoCodeModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        seedIfNeeded(context: container.viewContext)
    }

    private func seedIfNeeded(context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        fetch.fetchLimit = 1
        if let count = try? context.count(for: fetch), count > 0 {
            return
        }

        let questions: [(String, [String], Int)] = [
            ("Qual a palavra-chave para declarar uma variável mutável em Kotlin?", ["let", "var", "val", "mut"], 1),
            ("Qual é a função de entrada padrão em Kotlin?", ["start()", "main()", "run()", "init()"], 1),
            ("Qual tipo representa um valor que pode ser nulo em Kotlin?", ["String", "String?", "Optional<String>", "Nullable<String>"], 1),
            ("Como declarar uma função em Kotlin?", ["func name() {}", "def name() {}", "fun name() {}", "function name() {}"], 2),
            ("Qual operador elvis em Kotlin?", ["?:", "??", "?.", "!!"], 0),
            ("Como criar um singleton em Kotlin?", ["object MySingleton {}", "singleton My {}", "class My {}", "static object My {}"], 0),
            ("Qual coleção é imutável por padrão?", ["mutableListOf()", "arrayListOf()", "listOf()", "hashMapOf()"], 2),
            ("Qual o modificador de visibilidade padrão em Kotlin?", ["public", "internal", "private", "protected"], 1),
            ("Qual é o operador de safe call?", ["!!", "?.", "?:", "::"], 1),
            ("Como declarar uma data class?", ["class User()", "data class User()", "struct User", "record User()"], 1)
        ]

        for (text, options, correctIndex) in questions {
            let entity = QuestionEntity(context: context)
            entity.id = UUID()
            entity.text = text
            entity.correctIndex = Int16(correctIndex)
            entity.optionsData = try? JSONEncoder().encode(options)
        }

        do {
            try context.save()
        } catch {
            print("Seed save error: \(error)")
        }
    }
}

// MARK: - QuestionEntity generated subclass
@objc(QuestionEntity)
public class QuestionEntity: NSManagedObject {}

extension QuestionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestionEntity> {
        return NSFetchRequest<QuestionEntity>(entityName: "QuestionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var optionsData: Data?
    @NSManaged public var correctIndex: Int16

    var options: [String] {
        guard let data = optionsData, let arr = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return arr
    }
}
