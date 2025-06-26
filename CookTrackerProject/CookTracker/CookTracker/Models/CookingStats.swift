import Foundation
import CoreData

/// 調理統計計算のためのユーティリティクラス
struct CookingStats {
    
    /// 総調理日数を計算
    /// - Parameter records: 調理記録の配列
    /// - Returns: 調理を行った日数
    static func totalCookingDays(from records: [CookingRecord]) -> Int {
        let calendar = Calendar.current
        let uniqueDates = Set(records.compactMap { record -> Date? in
            guard let cookedAt = record.cookedAt else { return nil }
            return calendar.startOfDay(for: cookedAt)
        })
        return uniqueDates.count
    }
    
    /// 現在の連続調理日数を計算
    /// - Parameter records: 調理記録の配列（日付でソート済みであることを前提）
    /// - Returns: 連続調理日数
    static func currentStreakDays(from records: [CookingRecord]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 日付ごとにグループ化
        let recordsByDate = Dictionary(grouping: records) { record -> Date in
            guard let cookedAt = record.cookedAt else { return Date.distantPast }
            return calendar.startOfDay(for: cookedAt)
        }
        
        // 調理した日付を降順でソート
        let cookingDates = recordsByDate.keys
            .filter { $0 != Date.distantPast }
            .sorted(by: >)
        
        guard !cookingDates.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = today
        
        // 今日から過去に向かって連続日数をカウント
        for date in cookingDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if date < currentDate {
                // 日付が飛んでいる場合は連続終了
                break
            }
        }
        
        return streak
    }
    
    /// 最長連続調理日数を計算
    /// - Parameter records: 調理記録の配列
    /// - Returns: 最長連続調理日数
    static func longestStreakDays(from records: [CookingRecord]) -> Int {
        let calendar = Calendar.current
        
        // 日付ごとにグループ化
        let recordsByDate = Dictionary(grouping: records) { record -> Date in
            guard let cookedAt = record.cookedAt else { return Date.distantPast }
            return calendar.startOfDay(for: cookedAt)
        }
        
        // 調理した日付を昇順でソート
        let cookingDates = recordsByDate.keys
            .filter { $0 != Date.distantPast }
            .sorted()
        
        guard !cookingDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<cookingDates.count {
            let previousDate = cookingDates[i-1]
            let currentDate = cookingDates[i]
            
            // 前の日から1日後かどうかをチェック
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(nextDay, inSameDayAs: currentDate) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    /// 今週の調理日数を計算
    /// - Parameter records: 調理記録の配列
    /// - Returns: 今週の調理日数
    static func thisWeekCookingDays(from records: [CookingRecord]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return 0
        }
        
        let thisWeekRecords = records.filter { record -> Bool in
            guard let cookedAt = record.cookedAt else { return false }
            return weekInterval.contains(cookedAt)
        }
        
        return totalCookingDays(from: thisWeekRecords)
    }
    
    /// 今月の調理日数を計算
    /// - Parameter records: 調理記録の配列
    /// - Returns: 今月の調理日数
    static func thisMonthCookingDays(from records: [CookingRecord]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
            return 0
        }
        
        let thisMonthRecords = records.filter { record -> Bool in
            guard let cookedAt = record.cookedAt else { return false }
            return monthInterval.contains(cookedAt)
        }
        
        return totalCookingDays(from: thisMonthRecords)
    }
}

/// 調理統計表示用の構造体
struct CookingStatsData {
    let totalDays: Int
    let currentStreak: Int
    let longestStreak: Int
    let thisWeekDays: Int
    let thisMonthDays: Int
    let totalRecords: Int
    
    init(records: [CookingRecord]) {
        self.totalDays = CookingStats.totalCookingDays(from: records)
        self.currentStreak = CookingStats.currentStreakDays(from: records)
        self.longestStreak = CookingStats.longestStreakDays(from: records)
        self.thisWeekDays = CookingStats.thisWeekCookingDays(from: records)
        self.thisMonthDays = CookingStats.thisMonthCookingDays(from: records)
        self.totalRecords = records.count
    }
    
    /// 継続レベルの判定
    var continuityLevel: ContinuityLevel {
        if currentStreak >= 30 {
            return .master
        } else if currentStreak >= 14 {
            return .expert
        } else if currentStreak >= 7 {
            return .intermediate
        } else if currentStreak >= 3 {
            return .beginner
        } else {
            return .starter
        }
    }
    
    /// 継続レベルのメッセージ
    var continuityMessage: String {
        switch continuityLevel {
        case .master:
            return "🔥 調理マスター！素晴らしい継続力です"
        case .expert:
            return "⭐ 調理エキスパート！毎日頑張っていますね"
        case .intermediate:
            return "🌟 調理が習慣になってきました"
        case .beginner:
            return "👍 順調に調理を続けています"
        case .starter:
            return "🌱 調理を始めましょう"
        }
    }
}

/// 継続レベルの定義
enum ContinuityLevel {
    case starter      // 0-2日
    case beginner     // 3-6日
    case intermediate // 7-13日
    case expert       // 14-29日
    case master       // 30日以上
}