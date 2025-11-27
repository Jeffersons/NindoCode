//
//  QuestionRepository.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import Foundation
import CoreData

protocol QuestionRepositoryProtocol {
    func fetchAll() throws -> [QuestionEntity]
}

struct QuestionRepository: QuestionRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() throws -> [QuestionEntity] {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
}
