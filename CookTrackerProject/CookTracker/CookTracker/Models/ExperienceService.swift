// MARK: - Imports
import CoreData
import Foundation

/// 経験値管理サービス
/// - 経験値計算と付与の責任を担当
/// - レベルアップ判定とアニメーション制御
/// - 単一責任原則に基づく設計
class ExperienceService {
    
    // MARK: - Singleton
    static let shared = ExperienceService()
    private init() {}
    
    // MARK: - Experience Configuration
    private struct ExperienceConfig {
        static let baseExperience = 15
        static let difficultyMultiplier: [Int: Double] = [
            1: 0.8,  // 簡単: 12 XP
            2: 0.9,  // やや簡単: 13 XP
            3: 1.0,  // 普通: 15 XP
            4: 1.2,  // やや難しい: 18 XP
            5: 1.5   // 難しい: 22 XP
        ]
        static let completionBonusMultiplier = 1.1 // 写真・メモ完備時
    }
    
    // MARK: - Experience Calculation
    
    /// 調理完了時の経験値を計算
    /// - Parameters:
    ///   - recipe: レシピ（難易度含む）
    ///   - hasPhotos: 写真があるか
    ///   - hasNotes: メモがあるか
    /// - Returns: 獲得経験値
    func calculateExperience(for recipe: Recipe?, hasPhotos: Bool = false, hasNotes: Bool = false) -> Int {
        let baseXP = ExperienceConfig.baseExperience
        
        // 難易度による倍率
        let difficulty = Int(recipe?.difficulty ?? 3)
        let difficultyMultiplier = ExperienceConfig.difficultyMultiplier[difficulty] ?? 1.0
        
        // 完了度による倍率
        let completionMultiplier = (hasPhotos || hasNotes) ? ExperienceConfig.completionBonusMultiplier : 1.0
        
        let totalXP = Double(baseXP) * difficultyMultiplier * completionMultiplier
        return Int(totalXP.rounded())
    }
    
    /// 基本経験値を計算（レシピなしの場合）
    func calculateBasicExperience() -> Int {
        return ExperienceConfig.baseExperience
    }
    
    // MARK: - Experience Award
    
    /// ユーザーに経験値を付与
    /// - Parameters:
    ///   - user: 対象ユーザー
    ///   - experience: 付与する経験値
    /// - Returns: レベルアップしたかの真偽値
    @discardableResult
    func awardExperience(to user: User, amount: Int) -> Bool {
        let didLevelUp = user.addExperience(Int32(amount))
        
        if didLevelUp {
            AppLogger.levelUp(newLevel: Int(user.level), totalXP: Int(user.experiencePoints))
        } else {
            AppLogger.success("経験値獲得: +\(amount) XP (合計: \(user.experiencePoints) XP)")
        }
        
        return didLevelUp
    }
    
    // MARK: - Cooking Record Integration
    
    /// 調理記録作成と経験値付与を一括処理
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - recipe: レシピ
    ///   - cookingTime: 調理時間（分）
    ///   - hasPhotos: 写真があるか
    ///   - hasNotes: メモがあるか
    ///   - user: 対象ユーザー
    /// - Returns: (調理記録, レベルアップしたか, 獲得経験値)
    func createCookingRecordWithExperience(
        context: NSManagedObjectContext,
        recipe: Recipe?,
        cookingTime: Int,
        hasPhotos: Bool = false,
        hasNotes: Bool = false,
        user: User?
    ) -> (record: CookingRecord, didLevelUp: Bool, experience: Int) {
        
        // 経験値計算
        let experience = calculateExperience(for: recipe, hasPhotos: hasPhotos, hasNotes: hasNotes)
        
        // 調理記録作成
        let record = CookingRecord(context: context)
        record.id = UUID()
        record.recipeId = recipe?.id
        record.cookingTimeInMinutes = Int32(cookingTime)
        record.experienceGained = Int32(experience)
        record.cookedAt = Date()
        record.recipe = recipe
        
        // 経験値付与
        var didLevelUp = false
        if let user = user {
            didLevelUp = awardExperience(to: user, amount: experience)
        }
        
        return (record, didLevelUp, experience)
    }
    
    // MARK: - Quick Methods
    
    /// 基本調理記録を作成（レシピなし）
    func createBasicCookingRecord(
        context: NSManagedObjectContext,
        cookingTime: Int = 15,
        user: User?
    ) -> (record: CookingRecord, didLevelUp: Bool, experience: Int) {
        
        return createCookingRecordWithExperience(
            context: context,
            recipe: nil,
            cookingTime: cookingTime,
            user: user
        )
    }
}