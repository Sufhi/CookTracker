// MARK: - Imports
import SwiftUI

/// CookTrackerアプリのメインエントリーポイント
/// - 料理初心者向けのゲーミフィケーション要素を持つ自炊サポートアプリ
@main
struct CookTrackersApp: App {
    
    // MARK: - Properties
    // let persistenceController = PersistenceController.shared // Persistence.swiftファイルがプロジェクトに追加されるまで一時的にコメントアウト
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                // .environment(\.managedObjectContext, persistenceController.container.viewContext) // 一時的にコメントアウト
        }
    }
}
