// MARK: - Imports
import SwiftUI
import UserNotifications

/// CookTrackerアプリのメインエントリーポイント
/// - 料理初心者向けのゲーミフィケーション要素を持つ自炊サポートアプリ
@main
struct CookTrackersApp: App {
    
    // MARK: - Properties
    let persistenceController = PersistenceController.shared
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    setupNotifications()
                }
        }
    }
    
    // MARK: - Private Methods
    
    /// 通知設定の初期化
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ 通知権限が許可されました")
                } else {
                    print("⚠️ 通知権限が拒否されました")
                    if let error = error {
                        print("通知権限エラー: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // アプリがフォアグラウンドにある時も通知を表示
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // フォアグラウンドでも通知を表示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    // 通知タップ時の処理
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📱 通知がタップされました: \(response.notification.request.identifier)")
        completionHandler()
    }
}
