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
        
        // 初回起動時のデータセットアップ
        setupInitialDataIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Core Dataの保存
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data保存成功")
            } catch {
                print("❌ Core Data保存エラー: \(error.localizedDescription)")
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
                newUser.username = "料理初心者"
                save()
                print("✅ デフォルトユーザーを作成しました")
                return newUser
            }
        } catch {
            print("❌ ユーザー取得エラー: \(error.localizedDescription)")
            // エラーの場合も新規ユーザーを作成
            let newUser = User(context: context)
            save()
            return newUser
        }
    }
    
    // MARK: - Private Methods
    
    /// 初回起動時の初期データセットアップ
    private func setupInitialDataIfNeeded() {
        let context = container.viewContext
        
        // ユーザーの存在確認
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let userCount = try context.count(for: userRequest)
            if userCount == 0 {
                // 初回起動時: デフォルトユーザーを作成
                let defaultUser = User(context: context)
                defaultUser.username = "料理初心者"
                print("✅ 初回起動: デフォルトユーザーを作成")
                
                // レシピサンプルも作成
                createSampleRecipes(in: context)
                
                save()
            }
        } catch {
            print("❌ 初期データセットアップエラー: \(error.localizedDescription)")
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
            let recipe = Recipe(
                context: context,
                title: title,
                ingredients: ingredients,
                category: category,
                difficulty: Int32(difficulty),
                estimatedTime: Int32(time)
            )
            
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
        
        print("✅ サンプルレシピを作成しました")
    }
}