//
//  NindoCodeApp.swift
//  NindoCode
//
//  Created by Jefferson Batista on 26/11/25.
//

import SwiftUI
import CoreData

@main
struct NindoCodeApp: App {
    @State private var appCoordinator: AppCoordinator

    init() {
        let persistence = PersistenceController.shared
        _appCoordinator = State(initialValue: AppCoordinator(persistence: persistence))
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
        }
    }
}
