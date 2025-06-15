// MARK: - Imports
import Foundation
import CoreData

/// レシピ情報を管理するCore Dataエンティティ
/// - タイトル、材料、手順、難易度、カテゴリを保持
@objc(Recipe)
public class Recipe: NSManagedObject {
    
    // MARK: - Convenience Initializer
    convenience init(context: NSManagedObjectContext, title: String, ingredients: String, category: String = "食事", difficulty: Int32 = 2, estimatedTime: Int32 = 20) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: context) else {
            fatalError("Recipe entity not found in Core Data model")
        }
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.category = category
        self.difficulty = difficulty
        self.estimatedTimeInMinutes = estimatedTime
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// カテゴリの安全な取得（デフォルト値付き）
    var safeCategory: String {
        return category ?? "食事"
    }
    
    /// タイトルの安全な取得（デフォルト値付き）
    var safeTitle: String {
        return title ?? "無題のレシピ"
    }
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