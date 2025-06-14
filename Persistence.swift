// MARK: - Imports
import CoreData

/// Core Dataの管理とサンプルデータ作成を担当するクラス
/// - 永続化コンテナの設定とレシピサンプルデータの提供
struct PersistenceController {
    
    // MARK: - Shared Instance
    static let shared = PersistenceController()
    
    // MARK: - Preview Instance
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
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
        
        let sampleRecipe3 = Recipe(context: viewContext)
        sampleRecipe3.id = UUID()
        sampleRecipe3.title = "チキンカレー"
        sampleRecipe3.ingredients = "鶏肉 300g\n玉ねぎ 1個\nカレールー 1/2箱\nじゃがいも 2個\nにんじん 1本"
        sampleRecipe3.instructions = "1. 野菜を切る\n2. 鶏肉を炒める\n3. 野菜を炒める\n4. 水を加えて煮込む\n5. カレールーを溶かす"
        sampleRecipe3.category = "食事"
        sampleRecipe3.difficulty = 3
        sampleRecipe3.estimatedTimeInMinutes = 45
        sampleRecipe3.createdAt = Date()
        sampleRecipe3.updatedAt = Date()
        
        do {
            try viewContext.save()
            print("✅ サンプルレシピデータ作成成功")
        } catch {
            print("❌ サンプルデータ作成エラー: \(error.localizedDescription)")
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
                print("❌ Core Data読み込みエラー: \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data初期化成功")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}