//
//  AppCoordinator.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import SwiftUI
import CoreData

final class AppCoordinator {
    private let persistence: PersistenceController
    private let quizCoordinator: QuizCoordinator

    init(persistence: PersistenceController) {
        self.persistence = persistence
        self.quizCoordinator = QuizCoordinator(context: persistence.container.viewContext)
    }

    @ViewBuilder
    func start() -> some View {
        quizCoordinator.start()
    }
}
