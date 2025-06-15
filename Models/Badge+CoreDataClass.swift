// MARK: - Imports
import Foundation
import CoreData

/// バッジ情報を管理するCore Dataエンティティ
/// - バッジの種類と取得日時を保持
@objc(Badge)
public class Badge: NSManagedObject {
    
    // MARK: - Badge Types
    enum BadgeType: String, CaseIterable {
        case firstCooking = "first_cooking"
        case streak3 = "streak_3"
        case streak7 = "streak_7"
        case streak30 = "streak_30"
        case master10 = "master_10"
        case master50 = "master_50"
        case speedCooker = "speed_cooker"
        case perfectionist = "perfectionist"
        
        var title: String {
            switch self {
            case .firstCooking: return "初回調理"
            case .streak3: return "3日連続"
            case .streak7: return "1週間連続"
            case .streak30: return "1ヶ月連続"
            case .master10: return "料理マスター10"
            case .master50: return "料理マスター50"
            case .speedCooker: return "スピード調理"
            case .perfectionist: return "完璧主義者"
            }
        }
        
        var icon: String {
            switch self {
            case .firstCooking: return "🍳"
            case .streak3: return "🔥"
            case .streak7: return "⭐"
            case .streak30: return "👑"
            case .master10: return "🏆"
            case .master50: return "💎"
            case .speedCooker: return "⚡"
            case .perfectionist: return "💯"
            }
        }
    }
    
    // MARK: - Convenience Initializer
    convenience init(context: NSManagedObjectContext, type: BadgeType) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Badge", in: context) else {
            fatalError("Badge entity not found in Core Data model")
        }
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.badgeType = type.rawValue
        self.earnedAt = Date()
    }
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