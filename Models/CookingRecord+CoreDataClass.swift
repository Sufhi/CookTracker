// MARK: - Imports
import Foundation
import CoreData

/// 調理記録を管理するCore Dataエンティティ
/// - 調理時間、写真、メモ、獲得経験値を保持
@objc(CookingRecord)
public class CookingRecord: NSManagedObject {
    
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