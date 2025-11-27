//
//  ContentView.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let context: NSManagedObjectContext

    var body: some View {
        let coordinator = QuizCoordinator(context: context)
        coordinator.start()
    }
}

#Preview {
    ContentView(context: PersistenceController.shared.container.viewContext)
}
