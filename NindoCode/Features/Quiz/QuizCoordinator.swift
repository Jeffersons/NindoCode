//
//  QuizCoordinator.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import SwiftUI
import CoreData

final class QuizCoordinator {
    private let context: NSManagedObjectContext
    private let repository: QuestionRepositoryProtocol

    init(context: NSManagedObjectContext) {
        self.context = context
        self.repository = QuestionRepository(context: context)
    }

    @ViewBuilder
    func start() -> some View {
        let viewModel = QuizViewModel(repository: repository)
        QuizView(viewModel: viewModel)
    }
}
