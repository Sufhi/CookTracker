// MARK: - Imports
import Foundation
import CoreData

/// ユーザー情報を管理するCore Dataエンティティ
/// - レベル、経験値、登録状態を保持
@objc(User)
public class User: NSManagedObject {
    
}

// MARK: - Generated accessors
extension User {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var username: String?
    @NSManaged public var level: Int32
    @NSManaged public var experiencePoints: Int32
    @NSManaged public var isRegistered: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
}