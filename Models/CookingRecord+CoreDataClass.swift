// MARK: - Imports
import Foundation
import CoreData

/// 調理記録を管理するCore Dataエンティティ
/// - 調理時間、写真、メモ、獲得経験値を保持
@objc(CookingRecord)
public class CookingRecord: NSManagedObject {
    
    // MARK: - Convenience Initializer
    convenience init(context: NSManagedObjectContext, recipe: Recipe, cookingTime: Int32, experienceGained: Int32 = 15) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CookingRecord", in: context) else {
            fatalError("CookingRecord entity not found in Core Data model")
        }
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.recipeId = recipe.id
        self.cookingTimeInMinutes = cookingTime
        self.experienceGained = experienceGained
        self.cookedAt = Date()
        self.recipe = recipe
    }
    
    // MARK: - Computed Properties
    
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
    
    /// フォーマットされた調理日時
    var formattedCookedDate: String {
        guard let date = cookedAt else { return "不明" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    /// レシピタイトル（安全な取得）
    var recipeTitle: String {
        return recipe?.title ?? "不明なレシピ"
    }
}

// MARK: - Generated accessors
extension CookingRecord {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CookingRecord> {
        return NSFetchRequest<CookingRecord>(entityName: "CookingRecord")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var recipeId: UUID?
    @NSManaged public var cookingTimeInMinutes: Int32
    @NSManaged public var photoPaths: String?
    @NSManaged public var notes: String?
    @NSManaged public var experienceGained: Int32
    @NSManaged public var cookedAt: Date?
    @NSManaged public var recipe: Recipe?
    
}