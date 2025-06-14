// MARK: - Imports
import Foundation
import CoreData

/// レシピ情報を管理するCore Dataエンティティ
/// - タイトル、材料、手順、難易度、カテゴリを保持
@objc(Recipe)
public class Recipe: NSManagedObject {
    
}

// MARK: - Generated accessors
extension Recipe {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var instructions: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var category: String?
    @NSManaged public var difficulty: Int32
    @NSManaged public var estimatedTimeInMinutes: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var cookingRecords: NSSet?
    
}

// MARK: - Generated accessors for cookingRecords
extension Recipe {
    
    @objc(addCookingRecordsObject:)
    @NSManaged public func addToCookingRecords(_ value: CookingRecord)
    
    @objc(removeCookingRecordsObject:)
    @NSManaged public func removeFromCookingRecords(_ value: CookingRecord)
    
    @objc(addCookingRecords:)
    @NSManaged public func addToCookingRecords(_ values: NSSet)
    
    @objc(removeCookingRecords:)
    @NSManaged public func removeFromCookingRecords(_ values: NSSet)
    
}