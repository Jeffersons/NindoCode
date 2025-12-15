import SwiftUI
import CoreData

@main
struct NindoCodeApp: App {

    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let persistence = PersistenceController.shared
        _appCoordinator = StateObject(
            wrappedValue: AppCoordinator(persistence: persistence)
        )
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
        }
    }
}
