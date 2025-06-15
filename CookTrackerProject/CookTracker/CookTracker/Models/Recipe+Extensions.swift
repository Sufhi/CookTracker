// MARK: - Imports
import CoreData
import Foundation

// MARK: - Recipe Extension
extension Recipe {
    /// レシピカテゴリの表示名
    var categoryDisplayName: String {
        return category ?? "食事"
    }
    
    /// 難易度星表示用の配列
    var difficultyStars: [Bool] {
        let level = Int(difficulty)
        return (1...5).map { $0 <= level }
    }
    
    /// 推定時間の表示テキスト
    var estimatedTimeText: String {
        let minutes = Int(estimatedTimeInMinutes)
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
    
    /// レシピの作成日フォーマット
    var formattedCreatedDate: String {
        guard let date = createdAt else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    /// レシピの更新日フォーマット
    var formattedUpdatedDate: String {
        guard let date = updatedAt else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    /// URL の有効性チェック
    var hasValidURL: Bool {
        guard let urlString = url, !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }
    
    /// 有効な URL オブジェクト
    var validURL: URL? {
        guard let urlString = url, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}

// MARK: - Recipe Helper Methods
extension Recipe {
    /// レシピの一意識別用文字列
    var uniqueIdentifier: String {
        return id?.uuidString ?? objectID.uriRepresentation().absoluteString
    }
}