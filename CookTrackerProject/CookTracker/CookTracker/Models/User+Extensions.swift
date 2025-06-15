// MARK: - Imports
import CoreData
import Foundation

// MARK: - User Extension
extension User {
    /// 次のレベルまでの必要経験値
    var experienceToNextLevel: Int32 {
        let nextLevelXP = experienceForLevel(Int(level) + 1)
        let currentLevelXP = experienceForLevel(Int(level))
        return nextLevelXP - currentLevelXP - (experiencePoints - currentLevelXP)
    }
    
    /// 次のレベルまでの進捗率 (0.0-1.0)
    var progressToNextLevel: Double {
        let currentLevelXP = experienceForLevel(Int(level))
        let nextLevelXP = experienceForLevel(Int(level) + 1)
        let progressXP = experiencePoints - currentLevelXP
        let totalNeededXP = nextLevelXP - currentLevelXP
        
        guard totalNeededXP > 0 else { return 1.0 }
        return Double(progressXP) / Double(totalNeededXP)
    }
    
    /// レベルに必要な経験値を計算
    private func experienceForLevel(_ level: Int) -> Int32 {
        // レベル1: 0 XP, レベル2: 150 XP, レベル3: 350 XP...
        if level <= 1 { return 0 }
        return Int32(150 * level - 150)
    }
    
    /// 経験値を追加してレベルアップチェック
    @discardableResult
    func addExperience(_ amount: Int32) -> Bool {
        let oldLevel = level
        experiencePoints += amount
        updatedAt = Date()
        
        // レベルアップチェック
        let newLevel = calculateLevel(for: experiencePoints)
        if newLevel > oldLevel {
            level = newLevel
            return true // レベルアップした
        }
        return false // レベルアップしなかった
    }
    
    /// 経験値からレベルを計算
    private func calculateLevel(for xp: Int32) -> Int32 {
        var level: Int32 = 1
        while experienceForLevel(Int(level + 1)) <= xp {
            level += 1
        }
        return level
    }
}