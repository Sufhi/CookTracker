// MARK: - Imports
import Foundation
import CoreData

/// ユーザー情報を管理するCore Dataエンティティ
/// - レベル、経験値、登録状態を保持
@objc(User)
public class User: NSManagedObject {
    
    // MARK: - Convenience Initializer
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            fatalError("User entity not found in Core Data model")
        }
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.level = 1
        self.experiencePoints = 0
        self.isRegistered = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// 次のレベルまでに必要な経験値
    var experienceToNextLevel: Int32 {
        let nextLevelXP = levelToXP(level: Int(level) + 1)
        return nextLevelXP - experiencePoints
    }
    
    /// 現在のレベル内での進捗（0.0-1.0）
    var progressToNextLevel: Double {
        let currentLevelXP = levelToXP(level: Int(level))
        let nextLevelXP = levelToXP(level: Int(level) + 1)
        let levelRange = nextLevelXP - currentLevelXP
        let currentProgress = experiencePoints - currentLevelXP
        
        guard levelRange > 0 else { return 0.0 }
        return min(max(Double(currentProgress) / Double(levelRange), 0.0), 1.0)
    }
    
    // MARK: - Public Methods
    
    /// 経験値を追加してレベルアップ判定を行う
    /// - Parameter xp: 追加する経験値
    /// - Returns: レベルアップした場合はtrue
    @discardableResult
    func addExperience(_ xp: Int32) -> Bool {
        let oldLevel = level
        experiencePoints += xp
        
        // レベルアップ判定
        let newLevel = xpToLevel(xp: Int(experiencePoints))
        if newLevel > oldLevel {
            level = Int32(newLevel)
            updatedAt = Date()
            print("🎉 レベルアップ！ \(oldLevel) → \(level)")
            return true
        }
        
        updatedAt = Date()
        return false
    }
    
    // MARK: - Private Methods
    
    /// レベルから必要経験値を計算（指数関数的増加）
    private func levelToXP(level: Int) -> Int32 {
        if level <= 1 { return 0 }
        return Int32(100 * pow(1.5, Double(level - 1)))
    }
    
    /// 経験値からレベルを計算
    private func xpToLevel(xp: Int) -> Int32 {
        var level: Int32 = 1
        while levelToXP(level: Int(level + 1)) <= xp {
            level += 1
        }
        return level
    }
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