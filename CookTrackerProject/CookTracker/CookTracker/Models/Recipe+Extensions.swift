// MARK: - Imports
import CoreData
import Foundation
import UIKit

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
        guard let date = createdAt else { return "？" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    /// レシピの更新日フォーマット
    var formattedUpdatedDate: String {
        guard let date = updatedAt else { return "？" }
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
    
    /// サムネイル画像の有無チェック
    var hasThumbnail: Bool {
        guard let thumbnailPath = thumbnailImagePath, !thumbnailPath.isEmpty else { return false }
        return FileManager.default.fileExists(atPath: thumbnailPath)
    }
    
    /// サムネイル画像のUIImage
    var thumbnailImage: UIImage? {
        guard let thumbnailPath = thumbnailImagePath, !thumbnailPath.isEmpty else { return nil }
        return UIImage(contentsOfFile: thumbnailPath)
    }
    
    /// ドキュメントディレクトリのパスを取得
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// サムネイル画像を保存
    func saveThumbnailImage(_ image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        
        let fileName = "\(id?.uuidString ?? UUID().uuidString)_thumbnail.jpg"
        let fileURL = Recipe.documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            self.thumbnailImagePath = fileURL.path
            return true
        } catch {
            print("サムネイル保存エラー: \(error)")
            return false
        }
    }
    
    /// サムネイル画像を削除
    func deleteThumbnailImage() {
        guard let thumbnailPath = thumbnailImagePath, !thumbnailPath.isEmpty else { return }
        
        do {
            try FileManager.default.removeItem(atPath: thumbnailPath)
            self.thumbnailImagePath = nil
        } catch {
            print("サムネイル削除エラー: \(error)")
        }
    }
}

// MARK: - Recipe Helper Methods
extension Recipe {
    /// レシピの一意識別用文字列
    var uniqueIdentifier: String {
        return id?.uuidString ?? objectID.uriRepresentation().absoluteString
    }
}