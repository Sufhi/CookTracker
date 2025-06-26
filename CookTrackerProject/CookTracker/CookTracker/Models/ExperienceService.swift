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
        static let baseExperience = 20
        static let difficultyMultiplier: [Int: Double] = [
            1: 0.90,  // 簡単: 12 XP
            2: 0.95,  // やや簡単: 13 XP
            3: 1.0,  // 普通: 15 XP
            4: 1.05,  // やや難しい: 18 XP
            5: 1.1   // 難しい: 22 XP
        ]
        static let completionBonusMultiplier = 1.5 // 写真・メモ完備時
        
        // 時間精度ボーナス設定
        static let timePrecisionBonuses: [(tolerance: Double, bonus: Int)] = [
            (0.05, 30),  // ±5%以内: +30 XP
            (0.10, 20),  // ±10%以内: +20 XP
            (0.15, 10)   // ±15%以内: +10 XP
        ]
        
        // 連続調理ボーナス設定
        static let consecutiveCookingBonuses: [(days: Int, bonus: Int)] = [
            (30, 200),   // 30日連続: +200 XP
            (7, 50),     // 7日連続: +50 XP
            (2, 5)       // 2日連続: +5 XP
        ]
        
        // レシピ登録ボーナス設定
        static let recipeRegistrationBonus = 10  // 1日1回: +10 XP
        static let maxRecipeRegistrationsPerDay = 1  // 1日の制限回数
        
        // 難易度ボーナス設定
        static let difficultyBonuses: [Int: Int] = [
            4: 20,  // 星4: +20 XP
            5: 30   // 星5: +30 XP
        ]
        
        // カテゴリボーナス設定
        static let newCategoryBonus = 25  // 新カテゴリ初回: +25 XP
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
    
    /// 調理時間に基づく経験値を計算
    /// - Parameter cookingTimeInMinutes: 調理時間（分）
    /// - Returns: 獲得経験値
    func calculateExperience(for cookingTimeInMinutes: Int) -> Int {
        let baseXP = ExperienceConfig.baseExperience
        
        // 調理時間による倍率（15分基準）
        let timeMultiplier: Double
        if cookingTimeInMinutes <= 10 {
            timeMultiplier = 0.8
        } else if cookingTimeInMinutes <= 20 {
            timeMultiplier = 1.0
        } else if cookingTimeInMinutes <= 40 {
            timeMultiplier = 1.2
        } else {
            timeMultiplier = 1.5
        }
        
        let totalXP = Double(baseXP) * timeMultiplier
        return Int(totalXP.rounded())
    }
    
    /// 時間精度ボーナスを計算
    /// - Parameters:
    ///   - estimatedTimeInMinutes: 予想調理時間（分）
    ///   - actualTimeInMinutes: 実際の調理時間（分）
    /// - Returns: 精度ボーナス経験値
    func calculateTimePrecisionBonus(estimatedTimeInMinutes: Int, actualTimeInMinutes: Int) -> Int {
        // 0分の場合は計算不可
        guard estimatedTimeInMinutes > 0 else { return 0 }
        
        // 差の割合を計算
        let timeDifference = abs(actualTimeInMinutes - estimatedTimeInMinutes)
        let tolerance = Double(timeDifference) / Double(estimatedTimeInMinutes)
        
        // 最適なボーナスを検索（精度が高い順）
        for (requiredTolerance, bonus) in ExperienceConfig.timePrecisionBonuses {
            if tolerance <= requiredTolerance {
                return bonus
            }
        }
        
        return 0 // ボーナス対象外
    }
    
    /// 連続調理ボーナスを計算
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - referenceDate: 基準日（デフォルトは現在日時、テスト時は任意の日付を指定可能）
    /// - Returns: 連続調理ボーナス経験値
    func calculateConsecutiveCookingBonus(context: NSManagedObjectContext, referenceDate: Date = Date()) -> Int {
        let consecutiveDays = getCurrentConsecutiveCookingDays(context: context, referenceDate: referenceDate)
        
        // 最適なボーナスを検索（日数が多い順）
        for (requiredDays, bonus) in ExperienceConfig.consecutiveCookingBonuses {
            if consecutiveDays >= requiredDays {
                return bonus
            }
        }
        
        return 0 // ボーナス対象外
    }
    
    /// 現在の連続調理日数を取得
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - referenceDate: 基準日
    /// - Returns: 連続調理日数
    private func getCurrentConsecutiveCookingDays(context: NSManagedObjectContext, referenceDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        
        // 調理記録を日付順で取得
        let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)]
        
        do {
            let records = try context.fetch(request)
            var consecutiveDays = 0
            var currentCheckDate = today
            
            // 今日から過去に向かって連続日数をカウント
            while true {
                let hasRecordOnDate = records.contains { record in
                    guard let cookedAt = record.cookedAt else { return false }
                    return calendar.isDate(cookedAt, inSameDayAs: currentCheckDate)
                }
                
                if hasRecordOnDate {
                    consecutiveDays += 1
                    // 前の日をチェック
                    currentCheckDate = calendar.date(byAdding: .day, value: -1, to: currentCheckDate) ?? currentCheckDate
                } else {
                    // 連続が途切れた
                    break
                }
                
                // 安全のため100日で制限
                if consecutiveDays >= 100 {
                    break
                }
            }
            
            return consecutiveDays
            
        } catch {
            AppLogger.coreDataError("連続調理日数取得", error: error)
            return 0
        }
    }
    
    /// レシピ登録ボーナスが獲得可能かチェック
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - referenceDate: 基準日（デフォルトは現在日時、テスト時は任意の日付を指定可能）
    /// - Returns: ボーナス獲得可能な場合はtrue
    func canEarnRecipeRegistrationBonus(context: NSManagedObjectContext, referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        
        // 今日のDailyActivityを取得
        let dailyActivity = getOrCreateDailyActivity(context: context, date: today)
        
        // 制限回数をチェック
        return dailyActivity.recipeRegistrationCount < ExperienceConfig.maxRecipeRegistrationsPerDay
    }
    
    /// レシピ登録ボーナスを計算・記録
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - referenceDate: 基準日（デフォルトは現在日時）
    /// - Returns: 獲得した経験値（制限超過の場合は0）
    func processRecipeRegistrationBonus(context: NSManagedObjectContext, referenceDate: Date = Date()) -> Int {
        guard canEarnRecipeRegistrationBonus(context: context, referenceDate: referenceDate) else {
            return 0
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        
        // DailyActivityを更新
        let dailyActivity = getOrCreateDailyActivity(context: context, date: today)
        dailyActivity.recipeRegistrationCount += 1
        dailyActivity.lastRecipeRegistrationTime = referenceDate
        
        // Core Dataを保存
        do {
            try context.save()
        } catch {
            AppLogger.coreDataError("レシピ登録記録保存", error: error)
            return 0
        }
        
        return ExperienceConfig.recipeRegistrationBonus
    }
    
    /// DailyActivityエンティティを取得または作成
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - date: 対象日付
    /// - Returns: DailyActivityエンティティ
    private func getOrCreateDailyActivity(context: NSManagedObjectContext, date: Date) -> DailyActivity {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // 既存のDailyActivityを検索
        let request: NSFetchRequest<DailyActivity> = DailyActivity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            let activities = try context.fetch(request)
            if let existingActivity = activities.first {
                return existingActivity
            }
        } catch {
            AppLogger.coreDataError("DailyActivity検索", error: error)
        }
        
        // 新規作成
        let newActivity = DailyActivity(context: context)
        newActivity.id = UUID()
        newActivity.date = startOfDay
        newActivity.recipeRegistrationCount = 0
        newActivity.lastRecipeRegistrationTime = nil
        
        return newActivity
    }
    
    /// 難易度ボーナスを計算
    /// - Parameter difficulty: レシピの難易度（1-5）
    /// - Returns: 難易度ボーナス経験値
    func calculateDifficultyBonus(difficulty: Int) -> Int {
        return ExperienceConfig.difficultyBonuses[difficulty] ?? 0
    }
    
    /// 新カテゴリボーナスを計算・判定
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - category: レシピのカテゴリ
    /// - Returns: 新カテゴリの場合はボーナス経験値、既存カテゴリの場合は0
    func calculateNewCategoryBonus(context: NSManagedObjectContext, category: String) -> Int {
        // 指定カテゴリのレシピが既に存在するかチェック
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.fetchLimit = 1
        
        do {
            let existingRecipes = try context.fetch(request)
            // 既存のレシピがない場合は新カテゴリボーナス
            return existingRecipes.isEmpty ? ExperienceConfig.newCategoryBonus : 0
        } catch {
            AppLogger.coreDataError("カテゴリ検索", error: error)
            return 0
        }
    }
    
    /// 拡張経験値計算（難易度・カテゴリボーナス含む）
    /// - Parameters:
    ///   - context: Core Data コンテキスト
    ///   - recipe: レシピ（オプション）
    ///   - hasPhotos: 写真があるか
    ///   - hasNotes: メモがあるか
    ///   - isNewRecipe: 新規レシピかどうか（カテゴリボーナス判定用）
    /// - Returns: 合計獲得経験値
    func calculateEnhancedExperience(
        context: NSManagedObjectContext,
        recipe: Recipe?,
        hasPhotos: Bool = false,
        hasNotes: Bool = false,
        isNewRecipe: Bool = false
    ) -> Int {
        // 基本経験値（既に難易度倍率が適用済み）
        var totalXP = calculateExperience(for: recipe, hasPhotos: hasPhotos, hasNotes: hasNotes)
        
        // 追加の難易度ボーナス（星4-5のみ）
        if let recipe = recipe {
            let difficultyBonus = calculateDifficultyBonus(difficulty: Int(recipe.difficulty))
            totalXP += difficultyBonus
            
            // 新カテゴリボーナス（新規レシピの場合のみ）
            if isNewRecipe, let category = recipe.category {
                let categoryBonus = calculateNewCategoryBonus(context: context, category: category)
                totalXP += categoryBonus
            }
        }
        
        return totalXP
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
