// MARK: - Imports
import Foundation
import CoreData

/// バッジ情報を管理するCore Dataエンティティ
/// - バッジの種類と取得日時を保持
@objc(Badge)
public class Badge: NSManagedObject {
    
}

// MARK: - Generated accessors
extension Badge {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Badge> {
        return NSFetchRequest<Badge>(entityName: "Badge")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var badgeType: String?
    @NSManaged public var earnedAt: Date?
    
}