// MARK: - Imports
import SwiftUI

/// CookTrackerアプリのメインエントリーポイント
/// - 料理初心者向けのゲーミフィケーション要素を持つ自炊サポートアプリ
@main
struct CookTrackerApp: App {
    
    // MARK: - Properties
    let persistenceController = PersistenceController.shared
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}