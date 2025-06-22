//
//  ExperienceNotificationManager.swift
//  CookTracker
//
//  Created by Claude on 2025/06/21.
//

import SwiftUI
import Combine

/// 経験値獲得通知の管理クラス
/// - 経験値獲得情報をアプリ全体で共有
/// - ホーム画面で通知バーの表示制御
class ExperienceNotificationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ExperienceNotificationManager()
    
    // MARK: - Published Properties
    @Published var shouldShowNotification = false
    @Published var experienceGained: Int = 0
    @Published var didLevelUp: Bool = false
    @Published var oldLevel: Int = 0
    @Published var newLevel: Int = 0
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - Public Methods
    
    /// 経験値獲得通知をトリガー
    /// - Parameters:
    ///   - gained: 獲得した経験値
    ///   - levelUp: レベルアップしたかどうか
    ///   - oldLv: 旧レベル
    ///   - newLv: 新レベル
    func triggerExperienceNotification(
        gained: Int,
        levelUp: Bool,
        oldLv: Int,
        newLv: Int
    ) {
        DispatchQueue.main.async {
            self.experienceGained = gained
            self.didLevelUp = levelUp
            self.oldLevel = oldLv
            self.newLevel = newLv
            self.shouldShowNotification = true
            
            AppLogger.log("経験値通知トリガー - 獲得: \(gained)XP, レベルアップ: \(levelUp)", level: .info)
        }
    }
    
    /// 通知を非表示にする
    func dismissNotification() {
        DispatchQueue.main.async {
            self.shouldShowNotification = false
            
            // データをリセット
            self.experienceGained = 0
            self.didLevelUp = false
            self.oldLevel = 0
            self.newLevel = 0
            
            AppLogger.debug("経験値通知を非表示")
        }
    }
}