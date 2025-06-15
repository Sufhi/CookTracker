# cooktracker コーディングルール

## 1. 命名規則

### 1.1 ファイル・クラス名
```swift
// ✅ Good
RecipeListView.swift
CookingTimerViewModel.swift
CoreDataManager.swift

// ❌ Bad
recipeList.swift
cookingTimer.swift
dataManager.swift
```

### 1.2 変数・関数名
```swift
// ✅ Good - 明確で具体的
let selectedRecipe: Recipe
let cookingTimeInMinutes: Int
func startCookingTimer()
func saveRecipeToDatabase()

// ❌ Bad - 曖昧
let recipe: Recipe
let time: Int
func start()
func save()
```

### 1.3 Core Data関連
```swift
// ✅ Entity名
Recipe, CookingRecord, Badge

// ✅ 属性名
recipe.title, recipe.ingredients
cookingRecord.cookingTimeInMinutes
badge.earnedAt
```

## 2. コメント記述ルール

### 2.1 クラス・構造体
```swift
/// レシピ一覧を表示するメインビュー
/// - レシピの検索・フィルター機能を提供
/// - タップでレシピ詳細画面に遷移
struct RecipeListView: View {
    // ...
}
```

### 2.2 複雑な関数
```swift
/// 調理完了時の経験値計算と保存処理
/// - Parameters:
///   - recipe: 調理完了したレシピ
///   - cookingTime: 実際の調理時間（分）
/// - Returns: 獲得した経験値
func completeRecipe(_ recipe: Recipe, cookingTime: Int) -> Int {
    // 経験値計算ロジック
    let baseExperience = 10
    let timeBonus = cookingTime > 60 ? 5 : 0
    
    // Core Dataに保存
    saveCookingRecord(recipe: recipe, time: cookingTime)
    
    return baseExperience + timeBonus
}
```

### 2.3 TODO・FIXME
```swift
// TODO: フェーズ2でサブタイマー機能を追加
// FIXME: iOS 16以下での通知権限処理を修正
// MARK: - ゲーミフィケーション関連
```

## 3. ファイル構成

### 3.1 フォルダ構造
```
cooktracker/
├── Models/
│   ├── Recipe.swift
│   ├── CookingRecord.swift
│   └── CoreDataManager.swift
├── Views/
│   ├── Recipe/
│   │   ├── RecipeListView.swift
│   │   └── RecipeDetailView.swift
│   └── Timer/
│       └── CookingTimerView.swift
├── ViewModels/
│   ├── RecipeListViewModel.swift
│   └── CookingTimerViewModel.swift
└── Utils/
    ├── Extensions.swift
    └── Constants.swift
```

### 3.2 ファイル内構成
```swift
// MARK: - Imports
import SwiftUI
import CoreData

// MARK: - Main View
struct RecipeListView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = RecipeListViewModel()
    @State private var selectedRecipe: Recipe?
    
    // MARK: - Body
    var body: some View {
        // UI実装
    }
    
    // MARK: - Private Methods
    private func addNewRecipe() {
        // 実装
    }
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
```

## 4. SwiftUI特有ルール

### 4.1 State管理
```swift
// ✅ 明確な状態管理
@State private var isShowingAddRecipe = false
@State private var selectedDifficulty: Int = 1
@StateObject private var timerViewModel = CookingTimerViewModel()

// ❌ 曖昧
@State private var showing = false
@State private var selected = 1
```

### 4.2 ViewBuilder
```swift
// ✅ 複雑なViewは分割
var body: some View {
    VStack {
        headerSection
        recipeListSection
        addRecipeButton
    }
}

@ViewBuilder
private var headerSection: some View {
    // ヘッダー実装
}
```

## 5. Core Data関連

### 5.1 エラーハンドリング
```swift
// ✅ 適切なエラーハンドリング
func saveContext() {
    do {
        try context.save()
        print("✅ Core Data保存成功")
    } catch {
        print("❌ Core Data保存失敗: \(error.localizedDescription)")
    }
}
```

### 5.2 フェッチリクエスト
```swift
// ✅ 明確なフェッチリクエスト
func fetchRecipes(category: String? = nil) -> [Recipe] {
    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    
    if let category = category {
        request.predicate = NSPredicate(format: "category == %@", category)
    }
    
    request.sortDescriptors = [
        NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)
    ]
    
    // 実装
}
```

## 6. 将来拡張への配慮

### 6.1 プロトコル活用
```swift
// ゲーミフィケーション機能の将来拡張を見越した設計
protocol ExperienceCalculatable {
    func calculateExperience(for recipe: Recipe, cookingTime: Int) -> Int
}

protocol BadgeEarnable {
    func checkForNewBadges(after action: CookingAction) -> [Badge]
}
```

### 6.2 設定値の外部化
```swift
// Constants.swift
enum AppConstants {
    enum Experience {
        static let baseRecipeCompletion = 10
        static let timeBonusThreshold = 60
        static let timeBonus = 5
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 8
        static let spacing: CGFloat = 16
    }
}
```

## 7. テスト考慮

### 7.1 テスタブルな設計
```swift
// ✅ テストしやすい関数
func formatCookingTime(_ minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    
    if hours > 0 {
        return "\(hours)時間\(remainingMinutes)分"
    } else {
        return "\(remainingMinutes)分"
    }
}
```

## 8. パフォーマンス考慮

### 8.1 画像処理
```swift
// ✅ 画像サイズ制限とメモリ管理
func resizeImageForRecipe(_ image: UIImage) -> UIImage {
    let maxSize: CGFloat = 800
    // リサイズ実装
}
```

### 8.2 レイジーローディング
```swift
// ✅ 大量データの効率的な表示
LazyVStack {
    ForEach(recipes) { recipe in
        RecipeRowView(recipe: recipe)
    }
}
```

---

## Claude Code使用時の指示例

Claude Codeに以下のように指示：

> "このコーディングルールに従って実装してください。特に命名規則とコメント記述ルールを重視してください。"

> "新しい機能を追加する際は、将来拡張への配慮も含めて設計してください。"