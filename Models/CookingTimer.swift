// MARK: - Imports
import Foundation
import SwiftUI
import UserNotifications
import UIKit

/// 調理タイマーのロジックを管理するクラス
/// - バックグラウンド動作対応
/// - 通知機能
/// - リアルタイム進捗表示
class CookingTimer: ObservableObject {
    
    // MARK: - Published Properties
    @Published var timeRemaining: TimeInterval = 0
    @Published var initialTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var isFinished = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startDate: Date?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var pausedTime: TimeInterval = 0    // 一時停止時の残り時間
    
    // MARK: - Computed Properties
    var progress: Double {
        guard initialTime > 0 else { return 0 }
        return (initialTime - timeRemaining) / initialTime
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    // MARK: - Initializer
    init() {
        requestNotificationPermission()
    }
    
    // MARK: - Public Methods
    
    /// タイマーを開始
    /// - Parameter duration: タイマー時間（秒）
    func startTimer(duration: TimeInterval) {
        guard duration > 0 else { return }
        
        initialTime = duration
        timeRemaining = duration
        isRunning = true
        isFinished = false
        startDate = Date()
        
        // バックグラウンドタスク開始
        startBackgroundTask()
        
        // タイマー開始
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // 通知スケジュール
        scheduleNotification(duration: duration)
        
        print("✅ 補助タイマー開始: \(duration)秒")
    }
    
    /// タイマーを停止
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // バックグラウンドタスク終了
        endBackgroundTask()
        
        // 通知キャンセル
        cancelNotification()
        
        print("⏹ 補助タイマー停止")
    }
    
    /// タイマーを一時停止
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        pausedTime = timeRemaining
        
        // バックグラウンドタスク終了
        endBackgroundTask()
        
        cancelNotification()
        
        print("⏸ 補助タイマー一時停止")
    }
    
    /// タイマーを再開
    func resumeTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        startDate = Date()
        
        // バックグラウンドタスク開始
        startBackgroundTask()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // 残り時間で通知スケジュール
        scheduleNotification(duration: timeRemaining)
        
        print("▶️ 補助タイマー再開")
    }
    
    /// タイマーをリセット
    func resetTimer() {
        stopTimer()
        timeRemaining = initialTime
        isFinished = false
        pausedTime = 0
        
        print("🔄 補助タイマーリセット")
    }
    
    /// クイック設定メソッド
    func setQuickTime(minutes: Int) {
        let duration = TimeInterval(minutes * 60)
        initialTime = duration
        timeRemaining = duration
        isFinished = false
    }
    
    // MARK: - Private Methods
    
    private func updateTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.objectWillChange.send()
            } else {
                self.timerFinished()
            }
        }
    }
    
    private func timerFinished() {
        stopTimer()
        isFinished = true
        
        // 完了通知
        sendCompletionNotification()
        
        print("🎉 補助タイマー完了！")
    }
    
    // MARK: - Background Task Management
    
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "CookingTimer") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    // MARK: - Notification Management
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知許可取得")
            } else {
                print("❌ 通知許可なし: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func scheduleNotification(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "調理完了！"
        content.body = "タイマーが終了しました。お疲れ様でした！"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "cooking-timer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 通知スケジュール失敗: \(error.localizedDescription)")
            } else {
                print("✅ 通知スケジュール成功")
            }
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cooking-timer"])
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 調理完了！"
        content.body = "タイマーが終了しました。美味しく出来上がりましたか？"
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: "cooking-completed", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 完了通知失敗: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Background Task Management
    
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "HelperTimer") { [weak self] in
            self?.endBackgroundTask()
        }
        print("🔄 補助タイマーバックグラウンドタスク開始: \(backgroundTaskID.rawValue)")
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            print("⏹ 補助タイマーバックグラウンドタスク終了: \(backgroundTaskID.rawValue)")
            backgroundTaskID = .invalid
        }
    }
}