// MARK: - Imports
import Foundation
import SwiftUI

/// 調理セッション用カウントアップタイマー
/// - 調理開始から調理終了までの実際の時間を記録
/// - カウントアップ方式（00:00から時間が増加）
/// - 調理記録への保存機能
class CookingSessionTimer: ObservableObject {
    
    // MARK: - Published Properties
    @Published var elapsedTime: TimeInterval = 0    // 経過時間（秒）
    @Published var isRunning = false                // 調理中フラグ
    @Published var isPaused = false                 // 一時停止フラグ
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startDate: Date?
    private var pausedDuration: TimeInterval = 0    // 一時停止累積時間
    private var lastPauseDate: Date?
    
    // MARK: - Computed Properties
    
    /// フォーマット済み経過時間（HH:MM:SS または MM:SS）
    var formattedElapsedTime: String {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// 経過時間（分単位）
    var elapsedMinutes: Int {
        Int(elapsedTime / 60)
    }
    
    /// 調理状態の説明文
    var statusText: String {
        if isRunning {
            return "調理中..."
        } else if isPaused {
            return "一時停止中"
        } else if elapsedTime > 0 {
            return "調理完了"
        } else {
            return "調理前"
        }
    }
    
    // MARK: - Public Methods
    
    /// 調理を開始
    func startCooking() {
        guard !isRunning else { return }
        
        if !isPaused {
            // 新規調理開始
            elapsedTime = 0
            pausedDuration = 0
            startDate = Date()
        } else {
            // 一時停止から再開
            if let lastPause = lastPauseDate {
                pausedDuration += Date().timeIntervalSince(lastPause)
            }
            isPaused = false
        }
        
        isRunning = true
        
        // タイマー開始（1秒間隔で更新）
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
        
        print("🍳 調理開始: \(Date())")
    }
    
    /// 調理を一時停止
    func pauseCooking() {
        guard isRunning else { return }
        
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = true
        lastPauseDate = Date()
        
        print("⏸ 調理一時停止: 経過時間 \(formattedElapsedTime)")
    }
    
    /// 調理を終了（完了）
    /// - Returns: 調理記録データ
    func finishCooking() -> CookingSessionRecord {
        // タイマー停止
        timer?.invalidate()
        timer = nil
        
        let finalElapsedTime = elapsedTime
        let record = CookingSessionRecord(
            startTime: startDate ?? Date(),
            endTime: Date(),
            elapsedTime: finalElapsedTime,
            pausedDuration: pausedDuration,
            actualCookingTime: finalElapsedTime - pausedDuration
        )
        
        // 状態リセット
        isRunning = false
        isPaused = false
        
        print("✅ 調理完了: 総時間 \(formattedElapsedTime), 実調理時間 \(record.formattedActualTime)")
        
        return record
    }
    
    /// 調理をキャンセル（リセット）
    func cancelCooking() {
        timer?.invalidate()
        timer = nil
        
        elapsedTime = 0
        pausedDuration = 0
        isRunning = false
        isPaused = false
        startDate = nil
        lastPauseDate = nil
        
        print("❌ 調理キャンセル")
    }
    
    // MARK: - Private Methods
    
    private func updateElapsedTime() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let startDate = self.startDate else { return }
            
            // 開始時からの総経過時間 - 一時停止累積時間
            let totalElapsed = Date().timeIntervalSince(startDate)
            self.elapsedTime = totalElapsed - self.pausedDuration
            
            self.objectWillChange.send()
        }
    }
}

// MARK: - CookingSessionRecord

/// 調理セッションの記録データ
struct CookingSessionRecord {
    let id = UUID()
    let startTime: Date         // 調理開始時刻
    let endTime: Date          // 調理終了時刻
    let elapsedTime: TimeInterval    // 総経過時間（一時停止含む）
    let pausedDuration: TimeInterval // 一時停止累積時間
    let actualCookingTime: TimeInterval // 実際の調理時間（一時停止除く）
    
    /// フォーマット済み実調理時間
    var formattedActualTime: String {
        let totalSeconds = Int(actualCookingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// フォーマット済み総時間
    var formattedTotalTime: String {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// 実調理時間（分単位）
    var actualMinutes: Int {
        Int(actualCookingTime / 60)
    }
}