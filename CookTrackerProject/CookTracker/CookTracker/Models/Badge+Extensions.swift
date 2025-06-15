// MARK: - Imports
import CoreData
import Foundation
import SwiftUI

// MARK: - Badge Extension
extension Badge {
    /// バッジタイプのEnum値
    var badgeTypeEnum: BadgeType? {
        guard let badgeTypeString = badgeType else { return nil }
        return BadgeType(rawValue: badgeTypeString)
    }
    
    /// バッジのタイトル
    var title: String {
        return badgeTypeEnum?.title ?? "不明なバッジ"
    }
    
    /// バッジの説明
    var badgeDescription: String {
        return badgeTypeEnum?.description ?? "説明なし"
    }
    
    /// バッジのアイコン名
    var iconName: String {
        return badgeTypeEnum?.iconName ?? "questionmark"
    }
    
    /// バッジの色
    var color: BadgeColor {
        return badgeTypeEnum?.color ?? .silver
    }
    
    /// 獲得日時のフォーマット表示
    var formattedEarnedDate: String {
        guard let date = earnedAt else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    /// 獲得からの経過時間
    var timeAgoText: String {
        guard let date = earnedAt else { return "不明" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// バッジの SwiftUI Color
    var swiftUIColor: Color {
        let rgb = color.primaryColor
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
    
    /// バッジのレア度（1-5）
    var rarity: Int {
        switch badgeTypeEnum {
        case .firstCook: return 1
        case .streak3: return 2
        case .speed30min: return 2
        case .photoMaster: return 3
        case .speed15min: return 3
        case .perfectTime: return 4
        case .streak7: return 4
        case .streak30: return 5
        case .none: return 1
        }
    }
    
    /// レア度に基づく境界線の太さ
    var borderWidth: CGFloat {
        switch rarity {
        case 1: return 1
        case 2: return 2
        case 3: return 3
        case 4: return 4
        case 5: return 5
        default: return 1
        }
    }
}