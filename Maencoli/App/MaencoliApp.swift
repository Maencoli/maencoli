import SwiftUI
import SwiftData

@main
struct MaencoliApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Book.self, Highlight.self, Note.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            BookshelfView()
        }
        .modelContainer(sharedModelContainer)
    }
}
