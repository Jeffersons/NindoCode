//
//  CoreDataModel.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import CoreData

enum CoreDataModelBuilder {
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Entity: QuestionEntity
        let questionEntity = NSEntityDescription()
        questionEntity.name = "QuestionEntity"
        questionEntity.managedObjectClassName = NSStringFromClass(QuestionEntity.self)

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let textAttr = NSAttributeDescription()
        textAttr.name = "text"
        textAttr.attributeType = .stringAttributeType
        textAttr.isOptional = false

        let optionsDataAttr = NSAttributeDescription()
        optionsDataAttr.name = "optionsData"
        optionsDataAttr.attributeType = .binaryDataAttributeType
        optionsDataAttr.isOptional = false

        let correctIndexAttr = NSAttributeDescription()
        correctIndexAttr.name = "correctIndex"
        correctIndexAttr.attributeType = .integer16AttributeType
        correctIndexAttr.isOptional = false

        questionEntity.properties = [idAttr, textAttr, optionsDataAttr, correctIndexAttr]
        model.entities = [questionEntity]
        return model
    }
}
