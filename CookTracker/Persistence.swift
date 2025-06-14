// MARK: - Imports
import CoreData

/// Core Dataの管理とサンプルデータ作成を担当するクラス
/// - 永続化コンテナの設定とプレビュー用データの提供
struct PersistenceController {
    
    // MARK: - Shared Instance
    static let shared = PersistenceController()
    
    // MARK: - Preview Instance
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // サンプルユーザーデータ作成
        let sampleUser = User(context: viewContext)
        sampleUser.id = UUID()
        sampleUser.username = "料理初心者"
        sampleUser.level = 3
        sampleUser.experiencePoints = 150
        sampleUser.isRegistered = false
        sampleUser.createdAt = Date()
        sampleUser.updatedAt = Date()
        
        // サンプルレシピデータ作成
        let sampleRecipe1 = Recipe(context: viewContext)
        sampleRecipe1.id = UUID()
        sampleRecipe1.title = "簡単オムライス"
        sampleRecipe1.ingredients = "卵 2個\nご飯 200g\nケチャップ 大さじ2\n玉ねぎ 1/4個\nベーコン 2枚"
        sampleRecipe1.instructions = "1. 玉ねぎとベーコンを炒める\n2. ご飯を加えてケチャップで味付け\n3. 卵でふわふわに包む"
        sampleRecipe1.category = "食事"
        sampleRecipe1.difficulty = 2
        sampleRecipe1.estimatedTimeInMinutes = 20
        sampleRecipe1.createdAt = Date()
        sampleRecipe1.updatedAt = Date()
        
        let sampleRecipe2 = Recipe(context: viewContext)
        sampleRecipe2.id = UUID()
        sampleRecipe2.title = "基本の味噌汁"
        sampleRecipe2.ingredients = "味噌 大さじ1\nだしの素 小さじ1\n豆腐 1/4丁\nわかめ 適量"
        sampleRecipe2.instructions = "1. 水400mlを沸騰させる\n2. だしの素を入れる\n3. 豆腐とわかめを加える\n4. 味噌を溶かす"
        sampleRecipe2.category = "食事"
        sampleRecipe2.difficulty = 1
        sampleRecipe2.estimatedTimeInMinutes = 10
        sampleRecipe2.createdAt = Date()
        sampleRecipe2.updatedAt = Date()
        
        // サンプル調理記録作成
        let sampleRecord = CookingRecord(context: viewContext)
        sampleRecord.id = UUID()
        sampleRecord.recipeId = sampleRecipe1.id
        sampleRecord.cookingTimeInMinutes = 22
        sampleRecord.notes = "初回にしては上手くできた！次はもう少し卵をふわふわにしたい。"
        sampleRecord.experienceGained = 15
        sampleRecord.cookedAt = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("❌ サンプルデータ作成エラー: \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // MARK: - Container
    let container: NSPersistentContainer
    
    // MARK: - Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CookTrackerDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("❌ Core Data読み込みエラー: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}