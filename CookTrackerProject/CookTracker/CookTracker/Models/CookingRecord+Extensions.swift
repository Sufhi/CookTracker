// MARK: - Imports
import Foundation
import CoreData

/// CookingRecord エンティティの拡張
/// - 統計計算と便利メソッドを提供
extension CookingRecord {
    /// フォーマットされた調理時間
    var formattedCookingTime: String {
        let minutes = Int(cookingTimeInMinutes)
        if minutes < 60 {
            return "\(minutes)分"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)時間"
            } else {
                return "\(hours)時間\(remainingMinutes)分"
            }
        }
    }
    /// フォーマットされた調理日時（詳細版）
    var formattedDetailedDate: String {
        guard let date = cookedAt else { return "？" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    /// フォーマットされた調理日時（短縮版）
    var formattedShortDate: String {
        guard let date = cookedAt else { return "？" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    /// 予想時間との比較結果
    var timeComparisonStatus: TimeComparisonStatus {
        guard let recipe = recipe else { return .unknown }
        let estimatedTime = recipe.estimatedTimeInMinutes
        let actualTime = cookingTimeInMinutes
        
        if actualTime < estimatedTime {
            return .faster
        } else if actualTime == estimatedTime {
            return .exact
        } else {
            return .slower
        }
    }
    
    /// 時間差（分）
    var timeDifference: Int32 {
        guard let recipe = recipe else { return 0 }
        return cookingTimeInMinutes - recipe.estimatedTimeInMinutes
    }
    
    /// 時間差の表示用文字列
    var timeDifferenceText: String {
        let diff = timeDifference
        if diff == 0 {
            return "予想通り"
        } else if diff > 0 {
            return "+\(diff)分"
        } else {
            return "\(diff)分"
        }
    }
    
    /// 写真の枚数
    var photoCount: Int {
        guard let paths = photoPaths as? [String] else { return 0 }
        return paths.count
    }
    
    /// メモの有無
    var hasNotes: Bool {
        return notes != nil && !notes!.isEmpty
    }
    
    /// 写真の有無
    var hasPhotos: Bool {
        return photoCount > 0
    }
}

/// 時間比較の結果
enum TimeComparisonStatus {
    case faster   // 予想より早い
    case exact    // 予想通り
    case slower   // 予想より遅い
    case unknown  // 不明
    
    var color: String {
        switch self {
        case .faster: return "green"
        case .exact: return "yellow" 
        case .slower: return "orange"
        case .unknown: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .faster: return "checkmark.circle.fill"
        case .exact: return "equal.circle.fill"
        case .slower: return "clock.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Array Extensions for Statistics

extension Array where Element == CookingRecord {
    
    /// 統計情報の計算
    var cookingStatistics: CookingStatistics {
        guard !isEmpty else {
            return CookingStatistics(
                totalCount: 0,
                averageCookingTime: 0,
                shortestCookingTime: 0,
                longestCookingTime: 0,
                photoRecordsCount: 0,
                memoRecordsCount: 0,
                shortestRecord: nil,
                longestRecord: nil
            )
        }
        
        let cookingTimes = map { $0.cookingTimeInMinutes }
        let averageTime = Double(cookingTimes.reduce(0, +)) / Double(count)
        let shortestTime = cookingTimes.min() ?? 0
        let longestTime = cookingTimes.max() ?? 0
        
        let photoCount = filter { $0.hasPhotos }.count
        let memoCount = filter { $0.hasNotes }.count
        
        let shortestRecord = first { $0.cookingTimeInMinutes == shortestTime }
        let longestRecord = first { $0.cookingTimeInMinutes == longestTime }
        
        return CookingStatistics(
            totalCount: count,
            averageCookingTime: averageTime,
            shortestCookingTime: shortestTime,
            longestCookingTime: longestTime,
            photoRecordsCount: photoCount,
            memoRecordsCount: memoCount,
            shortestRecord: shortestRecord,
            longestRecord: longestRecord
        )
    }
    
    /// 月別の調理回数
    var monthlyCookingCounts: [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        var counts: [String: Int] = [:]
        for record in self {
            guard let date = record.cookedAt else { continue }
            let monthKey = formatter.string(from: date)
            counts[monthKey, default: 0] += 1
        }
        
        return counts
    }
    
    /// 最近7日間の調理記録
    var recentWeekRecords: [CookingRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return filter { record in
            guard let cookedAt = record.cookedAt else { return false }
            return cookedAt >= sevenDaysAgo
        }
    }
}

// MARK: - Statistics Data Structure

/// 調理統計情報
struct CookingStatistics {
    let totalCount: Int                    // 総調理回数
    let averageCookingTime: Double        // 平均調理時間
    let shortestCookingTime: Int32        // 最短調理時間
    let longestCookingTime: Int32         // 最長調理時間
    let photoRecordsCount: Int            // 写真付き記録数
    let memoRecordsCount: Int             // メモ付き記録数
    let shortestRecord: CookingRecord?    // 最短時間の記録
    let longestRecord: CookingRecord?     // 最長時間の記録
    
    /// 写真付き記録の割合（0.0-1.0）
    var photoRecordsRatio: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(photoRecordsCount) / Double(totalCount)
    }
    
    /// メモ付き記録の割合（0.0-1.0）
    var memoRecordsRatio: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(memoRecordsCount) / Double(totalCount)
    }
    
    /// フォーマットされた平均調理時間
    var formattedAverageTime: String {
        let minutes = Int(averageCookingTime.rounded())
        if minutes < 60 {
            return "\(minutes)分"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)時間"
            } else {
                return "\(hours)時間\(remainingMinutes)分"
            }
        }
    }
    
    /// フォーマットされた最短時間
    var formattedShortestTime: String {
        return formatTime(Int32(shortestCookingTime))
    }
    
    /// フォーマットされた最長時間
    var formattedLongestTime: String {
        return formatTime(Int32(longestCookingTime))
    }
    
    /// 時間フォーマット用のヘルパー
    private func formatTime(_ minutes: Int32) -> String {
        let min = Int(minutes)
        if min < 60 {
            return "\(min)分"
        } else {
            let hours = min / 60
            let remainingMinutes = min % 60
            if remainingMinutes == 0 {
                return "\(hours)時間"
            } else {
                return "\(hours)時間\(remainingMinutes)分"
            }
        }
    }
}
