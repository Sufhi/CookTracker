// MARK: - Imports
import Foundation
import CoreData

// MARK: - Badge Types
enum BadgeType: String, CaseIterable {
    case firstCook = "first_cook"           // 初回調理
    case streak3 = "streak_3"               // 3日連続調理
    case streak7 = "streak_7"               // 7日連続調理
    case streak30 = "streak_30"             // 30日連続調理
    case speed15min = "speed_15min"         // 15分以内調理
    case speed30min = "speed_30min"         // 30分以内調理
    case perfectTime = "perfect_time"       // 予想時間ぴったり調理
    case photoMaster = "photo_master"       // 写真10枚投稿
    
    var title: String {
        switch self {
        case .firstCook: return "料理デビュー"
        case .streak3: return "3日連続シェフ"
        case .streak7: return "週間シェフ"
        case .streak30: return "月間シェフ"
        case .speed15min: return "スピードクッカー"
        case .speed30min: return "クイッククッカー"
        case .perfectTime: return "時間マスター"
        case .photoMaster: return "フォトグラファー"
        }
    }
    
    var description: String {
        switch self {
        case .firstCook: return "初めて料理を完了しました"
        case .streak3: return "3日連続で料理を作りました"
        case .streak7: return "7日連続で料理を作りました"
        case .streak30: return "30日連続で料理を作りました"
        case .speed15min: return "15分以内で料理を完了しました"
        case .speed30min: return "30分以内で料理を完了しました"
        case .perfectTime: return "予想時間ぴったりで料理を完了しました"
        case .photoMaster: return "料理写真を10枚投稿しました"
        }
    }
    
    var iconName: String {
        switch self {
        case .firstCook: return "star.fill"
        case .streak3: return "flame.fill"
        case .streak7: return "crown.fill"
        case .streak30: return "trophy.fill"
        case .speed15min: return "bolt.fill"
        case .speed30min: return "timer"
        case .perfectTime: return "target"
        case .photoMaster: return "camera.fill"
        }
    }
    
    var color: BadgeColor {
        switch self {
        case .firstCook: return .gold
        case .streak3: return .orange
        case .streak7: return .purple
        case .streak30: return .rainbow
        case .speed15min: return .blue
        case .speed30min: return .green
        case .perfectTime: return .red
        case .photoMaster: return .pink
        }
    }
}

// MARK: - Badge Colors
enum BadgeColor {
    case gold, silver, bronze, blue, green, red, purple, orange, pink, rainbow
    
    var primaryColor: (red: Double, green: Double, blue: Double) {
        switch self {
        case .gold: return (1.0, 0.84, 0.0)
        case .silver: return (0.75, 0.75, 0.75)
        case .bronze: return (0.8, 0.5, 0.2)
        case .blue: return (0.0, 0.48, 1.0)
        case .green: return (0.2, 0.78, 0.35)
        case .red: return (1.0, 0.23, 0.19)
        case .purple: return (0.64, 0.32, 0.95)
        case .orange: return (1.0, 0.58, 0.0)
        case .pink: return (1.0, 0.18, 0.33)
        case .rainbow: return (0.5, 0.5, 1.0) // 基本色、実際はグラデーション
        }
    }
}

// MARK: - Badge System Manager
class BadgeSystem: ObservableObject {
    static let shared = BadgeSystem()
    
    private let viewContext: NSManagedObjectContext
    @Published var newlyEarnedBadges: [BadgeType] = []
    
    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    // MARK: - Public Methods
    
    /// 調理完了時のバッジチェック
    func checkBadgesForCookingCompletion(
        user: User,
        cookingRecord: CookingRecord,
        photoCount: Int = 0
    ) -> [BadgeType] {
        var newBadges: [BadgeType] = []
        
        // 初回調理バッジ
        if let firstCookBadge = checkFirstCookBadge(user: user) {
            newBadges.append(firstCookBadge)
        }
        
        // 連続調理バッジ
        if let streakBadge = checkStreakBadges(user: user) {
            newBadges.append(streakBadge)
        }
        
        // スピード調理バッジ
        if let speedBadge = checkSpeedBadges(cookingRecord: cookingRecord) {
            newBadges.append(speedBadge)
        }
        
        // 時間マスターバッジ
        if let timeBadge = checkPerfectTimeBadge(cookingRecord: cookingRecord) {
            newBadges.append(timeBadge)
        }
        
        // 写真マスターバッジ
        if let photoBadge = checkPhotoMasterBadge(user: user, additionalPhotos: photoCount) {
            newBadges.append(photoBadge)
        }
        
        // 新しいバッジを保存
        for badgeType in newBadges {
            saveBadge(badgeType: badgeType, user: user)
        }
        
        // 通知用に更新
        DispatchQueue.main.async {
            self.newlyEarnedBadges = newBadges
        }
        
        return newBadges
    }
    
    /// ユーザーの取得済みバッジ一覧
    func getUserBadges(user: User) -> [Badge] {
        guard let badges = user.badges as? Set<Badge> else {
            return []
        }
        
        // 日付順でソート
        return badges.sorted { badge1, badge2 in
            guard let date1 = badge1.earnedAt, let date2 = badge2.earnedAt else {
                return false
            }
            return date1 > date2
        }
    }
    
    /// バッジが取得済みかチェック
    func hasBadge(user: User, badgeType: BadgeType) -> Bool {
        guard let badges = user.badges as? Set<Badge> else {
            return false
        }
        
        return badges.contains { badge in
            badge.badgeType == badgeType.rawValue
        }
    }
    
    // MARK: - Private Methods
    
    /// 初回調理バッジチェック
    private func checkFirstCookBadge(user: User) -> BadgeType? {
        if !hasBadge(user: user, badgeType: .firstCook) {
            let cookingCount = getCookingRecordCount(user: user)
            if cookingCount == 1 { // 今回が初回
                return .firstCook
            }
        }
        return nil
    }
    
    /// 連続調理バッジチェック
    private func checkStreakBadges(user: User) -> BadgeType? {
        let currentStreak = getCurrentCookingStreak(user: user)
        
        // 30日連続（最高レベル）
        if currentStreak >= 30 && !hasBadge(user: user, badgeType: .streak30) {
            return .streak30
        }
        // 7日連続
        else if currentStreak >= 7 && !hasBadge(user: user, badgeType: .streak7) {
            return .streak7
        }
        // 3日連続
        else if currentStreak >= 3 && !hasBadge(user: user, badgeType: .streak3) {
            return .streak3
        }
        
        return nil
    }
    
    /// スピード調理バッジチェック
    private func checkSpeedBadges(cookingRecord: CookingRecord) -> BadgeType? {
        let cookingTimeMinutes = Int(cookingRecord.cookingTimeInMinutes)
        
        if cookingTimeMinutes <= 15 {
            return .speed15min
        } else if cookingTimeMinutes <= 30 {
            return .speed30min
        }
        
        return nil
    }
    
    /// 時間マスターバッジチェック
    private func checkPerfectTimeBadge(cookingRecord: CookingRecord) -> BadgeType? {
        guard let recipe = cookingRecord.recipe else { return nil }
        
        let actualTime = Int(cookingRecord.cookingTimeInMinutes)
        let estimatedTime = Int(recipe.estimatedTimeInMinutes)
        
        // 予想時間の±2分以内なら「ぴったり」とみなす
        if abs(actualTime - estimatedTime) <= 2 {
            return .perfectTime
        }
        
        return nil
    }
    
    /// 写真マスターバッジチェック
    private func checkPhotoMasterBadge(user: User, additionalPhotos: Int) -> BadgeType? {
        if !hasBadge(user: user, badgeType: .photoMaster) {
            let totalPhotos = getTotalPhotoCount(user: user) + additionalPhotos
            if totalPhotos >= 10 {
                return .photoMaster
            }
        }
        return nil
    }
    
    /// バッジを保存
    private func saveBadge(badgeType: BadgeType, user: User) {
        let badge = Badge(context: viewContext)
        badge.id = UUID()
        badge.badgeType = badgeType.rawValue
        badge.earnedAt = Date()
        badge.user = user // Core Data関係性を設定
        
        PersistenceController.shared.save()
        AppLogger.badgeEarned(badgeType.title)
    }
    
    /// 調理記録数を取得
    private func getCookingRecordCount(user: User) -> Int {
        guard let cookingRecords = user.cookingRecords as? Set<CookingRecord> else {
            // 関係性が設定されていない場合は全記録をカウント
            let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
            do {
                let records = try viewContext.fetch(request)
                return records.count
            } catch {
                AppLogger.error("調理記録数取得エラー", error: error)
                return 0
            }
        }
        
        return cookingRecords.count
    }
    
    /// 現在の連続調理日数を取得
    private func getCurrentCookingStreak(user: User) -> Int {
        guard let cookingRecords = user.cookingRecords as? Set<CookingRecord> else {
            // 関係性が設定されていない場合は全記録を使用
            let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)]
            
            do {
                let records = try viewContext.fetch(request)
                return calculateStreak(from: records)
            } catch {
                AppLogger.error("連続調理日数取得エラー", error: error)
                return 0
            }
        }
        
        // 日付順でソート
        let sortedRecords = cookingRecords.sorted { record1, record2 in
            guard let date1 = record1.cookedAt, let date2 = record2.cookedAt else {
                return false
            }
            return date1 > date2
        }
        
        return calculateStreak(from: sortedRecords)
    }
    
    /// 連続日数を計算
    private func calculateStreak(from records: [CookingRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var previousDate: Date?
        
        // 今日から逆算して連続日数をカウント
        let today = calendar.startOfDay(for: Date())
        var checkDate = today
        
        for record in records {
            guard let cookedAt = record.cookedAt else { continue }
            let recordDate = calendar.startOfDay(for: cookedAt)
            
            if calendar.isDate(recordDate, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if recordDate < checkDate {
                // 連続が途切れた
                break
            }
        }
        
        return streak
    }
    
    /// 総写真数を取得
    private func getTotalPhotoCount(user: User) -> Int {
        guard let cookingRecords = user.cookingRecords as? Set<CookingRecord> else {
            // 関係性が設定されていない場合は全記録を使用
            let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
            
            do {
                let records = try viewContext.fetch(request)
                var totalPhotos = 0
                
                for record in records {
                    // photoPaths が配列として保存されている場合
                    if let photoPaths = record.photoPaths as? [String] {
                        totalPhotos += photoPaths.count
                    }
                }
                
                return totalPhotos
            } catch {
                AppLogger.error("写真数取得エラー", error: error)
                return 0
            }
        }
        
        var totalPhotos = 0
        
        for record in cookingRecords {
            // photoPaths が配列として保存されている場合
            if let photoPaths = record.photoPaths as? [String] {
                totalPhotos += photoPaths.count
            }
        }
        
        return totalPhotos
    }
}