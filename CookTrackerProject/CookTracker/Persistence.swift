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
            AppLogger.coreDataSuccess("サンプルレシピデータ作成")
        } catch {
            AppLogger.coreDataError("サンプルデータ作成", error: error)
        }
        
        return controller
    }()
    
    // MARK: - Container
    let container: NSPersistentContainer
    
    // MARK: - Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CookTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Core Data マイグレーション設定
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldMigrateStoreAutomatically = true
        storeDescription?.shouldInferMappingModelAutomatically = true
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { [container] _, error in
            if let error = error as NSError? {
                AppLogger.coreDataError("Core Data読み込み", error: error)
                // フォールバック処理: インメモリストアに切り替え
                Self.handleCoreDataLoadErrorStatic(container: container, error: error)
            } else {
                AppLogger.coreDataSuccess("Core Data初期化")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Public Methods
    
    /// Core Dataの保存
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                AppLogger.coreDataSuccess("Core Data保存")
            } catch {
                AppLogger.coreDataError("Core Data保存", error: error)
            }
        }
    }
    
    /// デフォルトユーザーを取得または作成
    func getOrCreateDefaultUser() -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(request)
            if let existingUser = users.first {
                return existingUser
            } else {
                // デフォルトユーザーを新規作成
                let newUser = User(context: context)
                newUser.id = UUID()
                newUser.username = "料理初心者"
                newUser.level = 1
                newUser.experiencePoints = 0
                newUser.isRegistered = false
                newUser.createdAt = Date()
                newUser.updatedAt = Date()
                
                // 初回起動時はサンプルレシピも作成
                createSampleRecipes(in: context)
                
                save()
                AppLogger.coreDataSuccess("デフォルトユーザー作成")
                return newUser
            }
        } catch {
            AppLogger.coreDataError("ユーザー取得", error: error)
            // エラーの場合も新規ユーザーを作成
            let newUser = User(context: context)
            newUser.id = UUID()
            newUser.username = "料理初心者"
            newUser.level = 1
            newUser.experiencePoints = 0
            newUser.isRegistered = false
            newUser.createdAt = Date()
            newUser.updatedAt = Date()
            save()
            return newUser
        }
    }
    
    // MARK: - Private Methods
    
    /// Core Data読み込みエラー時のフォールバック処理（静的版）
    private static func handleCoreDataLoadErrorStatic(container: NSPersistentContainer, error: NSError) {
        AppLogger.warning("Core Data初期化に失敗しました。インメモリストアでアプリを継続します。")
        
        // 既存のストアを削除してインメモリストアで再試行
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        storeDescription.shouldMigrateStoreAutomatically = false
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, fallbackError in
            if let fallbackError = fallbackError {
                AppLogger.error("インメモリストア初期化も失敗", error: fallbackError)
                // 最後の手段として最小限のデータモデルで続行
                AppLogger.warning("最小限の機能でアプリを継続します。")
            } else {
                AppLogger.coreDataSuccess("インメモリストアで初期化")
            }
        }
    }
    
    /// Core Data読み込みエラー時のフォールバック処理
    private func handleCoreDataLoadError(_ error: NSError) {
        AppLogger.warning("Core Data初期化に失敗しました。インメモリストアでアプリを継続します。")
        
        // 既存のストアを削除してインメモリストアで再試行
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        storeDescription.shouldMigrateStoreAutomatically = false
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, fallbackError in
            if let fallbackError = fallbackError {
                AppLogger.error("インメモリストア初期化も失敗", error: fallbackError)
                // 最後の手段として最小限のデータモデルで続行
                AppLogger.warning("最小限の機能でアプリを継続します。")
            } else {
                AppLogger.coreDataSuccess("インメモリストアで初期化")
            }
        }
    }
    
    /// サンプルレシピの作成
    private func createSampleRecipes(in context: NSManagedObjectContext) {
        let recipes = [
            ("簡単オムライス", "卵 2個\nご飯 200g\nケチャップ 大さじ2\n玉ねぎ 1/4個\nベーコン 2枚", "食事", 2, 20),
            ("基本の味噌汁", "味噌 大さじ1\nだしの素 小さじ1\n豆腐 1/4丁\nわかめ 適量", "食事", 1, 10),
            ("チキンカレー", "鶏肉 300g\n玉ねぎ 1個\nカレールー 1/2箱\nじゃがいも 2個\nにんじん 1本", "食事", 3, 45),
            ("フルーツサラダ", "りんご 1個\nバナナ 1本\nオレンジ 1個\nヨーグルト 大さじ2\nはちみつ 小さじ1", "デザート", 1, 10)
        ]
        
        for (title, ingredients, category, difficulty, time) in recipes {
            let recipe = Recipe(context: context)
            recipe.id = UUID()
            recipe.title = title
            recipe.ingredients = ingredients
            recipe.category = category
            recipe.difficulty = Int32(difficulty)
            recipe.estimatedTimeInMinutes = Int32(time)
            recipe.createdAt = Date()
            recipe.updatedAt = Date()
            
            // 手順も追加
            switch title {
            case "簡単オムライス":
                recipe.instructions = "1. 玉ねぎとベーコンを炒める\n2. ご飯を加えてケチャップで味付け\n3. 卵でふわふわに包む"
            case "基本の味噌汁":
                recipe.instructions = "1. 水400mlを沸騰させる\n2. だしの素を入れる\n3. 豆腐とわかめを加える\n4. 味噌を溶かす"
            case "チキンカレー":
                recipe.instructions = "1. 野菜を切る\n2. 鶏肉を炒める\n3. 野菜を炒める\n4. 水を加えて煮込む\n5. カレールーを溶かす"
            case "フルーツサラダ":
                recipe.instructions = "1. フルーツを一口大に切る\n2. ボウルに入れて混ぜる\n3. ヨーグルトとはちみつを加える"
            default:
                break
            }
        }
        
        AppLogger.coreDataSuccess("サンプルレシピ作成")
    }
}