# CookTracker - API・クラス設計ドキュメント

## 📋 概要

CookTrackerアプリの内部API、クラス設計、およびデータフロー詳細ドキュメントです。

## 🏗️ アーキテクチャ概要

### MVVM + Core Data パターン
```
View (SwiftUI) ↔ ViewModel (ObservableObject) ↔ Model (Core Data)
```

## 📊 Core Data エンティティ設計

### User Entity
```swift
class User: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var level: Int32
    @NSManaged public var experiencePoints: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // Relationships
    @NSManaged public var badges: NSSet?
    @NSManaged public var cookingRecords: NSSet?
}
```

#### User Extensions (User+Extensions.swift)
```swift
extension User {
    // レベル計算
    var experienceToNextLevel: Int32 { /* 次レベルまでの必要XP */ }
    var progressToNextLevel: Double { /* 次レベルまでの進捗率 */ }
    
    // 経験値追加（レベルアップ判定付き）
    @discardableResult
    func addExperience(_ amount: Int32) -> Bool { /* レベルアップしたらtrue */ }
    
    // レベル計算式
    private func experienceForLevel(_ level: Int) -> Int32 { 
        return Int32(level * level * 100) 
    }
    
    private func calculateLevel(for experience: Int32) -> Int32 {
        return Int32(floor(sqrt(Double(experience) / 100.0))) + 1
    }
}
```

### Recipe Entity
```swift
class Recipe: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var instructions: String?
    @NSManaged public var category: String?
    @NSManaged public var difficulty: Int32 // 1-5
    @NSManaged public var estimatedTimeInMinutes: Int32
    @NSManaged public var url: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // Relationships
    @NSManaged public var cookingRecords: NSSet?
}
```

### CookingRecord Entity
```swift
class CookingRecord: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var recipeId: UUID?
    @NSManaged public var cookingTimeInMinutes: Int32
    @NSManaged public var photoPaths: NSObject? // Array<String>
    @NSManaged public var notes: String?
    @NSManaged public var experienceGained: Int32
    @NSManaged public var cookedAt: Date?
    
    // Relationships
    @NSManaged public var recipe: Recipe?
    @NSManaged public var user: User?
}
```

### Badge Entity
```swift
class Badge: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var badgeType: String // BadgeType.rawValue
    @NSManaged public var earnedAt: Date?
    
    // Relationships
    @NSManaged public var user: User?
}
```

## 🎮 ゲーミフィケーション システム

### BadgeSystem.swift
```swift
class BadgeSystem: ObservableObject {
    static let shared = BadgeSystem()
    
    enum BadgeType: String, CaseIterable {
        // 基本バッジ
        case firstCook = "初回調理"
        
        // 連続調理バッジ
        case consecutiveCook3 = "連続調理3日"
        case consecutiveCook7 = "連続調理7日"
        case consecutiveCook30 = "連続調理30日"
        
        // スキルバッジ
        case speedCook = "スピード調理"
        case photoMaster = "写真マスター"
        case memoMaster = "メモマスター"
        
        // マスターバッジ
        case cookMaster10 = "料理マスター10"
        case cookMaster50 = "料理マスター50"
        case cookMaster100 = "料理マスター100"
        
        // 上級バッジ
        case challenger = "チャレンジャー"
        case expert = "熟練者"
    }
    
    enum BadgeRarity: String {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
    }
    
    // バッジチェック
    func checkBadgesForCookingCompletion(
        user: User, 
        cookingRecord: CookingRecord, 
        photoCount: Int = 0
    ) -> [BadgeType] { /* 新規獲得バッジを返す */ }
    
    // バッジ情報取得
    func getBadgeInfo(_ type: BadgeType) -> (rarity: BadgeRarity, description: String, icon: String)
    func getBadgeRarity(_ type: BadgeType) -> BadgeRarity
    func getBadgeDescription(_ type: BadgeType) -> String
    func getBadgeIcon(_ type: BadgeType) -> String
}
```

## ⏱️ タイマーシステム

### CookingSessionTimer.swift
```swift
class CookingSessionTimer: ObservableObject {
    // 公開プロパティ
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var elapsedTime: TimeInterval = 0
    
    // プライベートプロパティ
    private var timer: Timer?
    private var startTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var sessionStartTime: Date?
    
    // 計算プロパティ
    var formattedElapsedTime: String { /* MM:SS形式 */ }
    var statusText: String { /* "調理中" / "一時停止中" / "停止中" */ }
    
    // 主要メソッド
    func startCooking() { /* 調理開始 */ }
    func pauseCooking() { /* 一時停止 */ }
    func finishCooking() -> CookingSessionRecord { /* 調理完了・記録返却 */ }
    func cancelCooking() { /* 調理キャンセル */ }
    
    // プライベートメソッド
    private func startTimer() { /* 1秒間隔タイマー開始 */ }
    private func stopTimer() { /* タイマー停止 */ }
    private func updateElapsedTime() { /* 経過時間更新 */ }
}

// 調理セッション記録
struct CookingSessionRecord {
    let startTime: Date
    let endTime: Date
    let elapsedTime: TimeInterval
    let pausedDuration: TimeInterval
    let actualCookingTime: TimeInterval
    
    var formattedActualTime: String { /* 実際の調理時間フォーマット */ }
    var formattedCookingTime: String { /* 調理時間フォーマット */ }
    var actualMinutes: Int { /* 分単位の実際時間 */ }
}
```

### CookingTimer.swift
```swift
class CookingTimer: ObservableObject {
    // 公開プロパティ
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    @Published var isFinished = false
    
    // プライベートプロパティ
    private var timer: Timer?
    private var originalTime: TimeInterval = 0
    private var backgroundTime: Date?
    
    // 計算プロパティ
    var formattedTime: String { /* MM:SS形式 */ }
    var progress: Double { /* 進捗率 0.0-1.0 */ }
    
    // 主要メソッド
    func setTimer(minutes: Int) { /* タイマー設定 */ }
    func startTimer() { /* タイマー開始 */ }
    func pauseTimer() { /* 一時停止 */ }
    func resumeTimer() { /* 再開 */ }
    func resetTimer() { /* リセット */ }
    
    // バックグラウンド対応
    func handleAppBackground() { /* バックグラウンド移行時 */ }
    func handleAppForeground() { /* フォアグラウンド復帰時 */ }
    
    // 通知
    private func scheduleNotification() { /* 完了通知スケジュール */ }
    private func cancelNotification() { /* 通知キャンセル */ }
}
```

## 💾 データ管理

### PersistenceController.swift
```swift
class PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = { /* プレビュー用 */ }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Core Data設定
        // 自動マイグレーション設定
        // リモート変更通知設定
    }
    
    // 保存メソッド
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
    
    // ユーザー取得・作成
    func getOrCreateDefaultUser() -> User {
        // デフォルトユーザーの取得または新規作成
    }
    
    // サンプルデータ作成
    private func createSampleDataIfNeeded() {
        // 初回起動時のサンプルレシピ作成
    }
}
```

## 🖼️ UI コンポーネント設計

### Main Views

#### SimpleHomeView.swift
```swift
struct SimpleHomeView: View {
    // Core Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(...) private var suggestedRecipes: FetchedResults<Recipe>
    @FetchRequest(...) private var recentCookingRecords: FetchedResults<CookingRecord>
    
    // State
    @State private var currentUser: User?
    @StateObject private var cookingSession = CookingSessionTimer()
    @StateObject private var helperTimer = CookingTimer()
    
    // Computed Properties
    private var userLevel: Int { Int(currentUser?.level ?? 1) }
    private var userExperience: Int { Int(currentUser?.experiencePoints ?? 0) }
    private var userProgress: Double { currentUser?.progressToNextLevel ?? 0.0 }
    
    // View Components
    @ViewBuilder private var userInfoSection: some View { /* ユーザー情報 */ }
    @ViewBuilder private var todaysSuggestionSection: some View { /* 今日の提案 */ }
    @ViewBuilder private var quickActionSection: some View { /* クイックアクション */ }
    @ViewBuilder private var recentHistorySection: some View { /* 最近の履歴 */ }
    @ViewBuilder private var cookingSessionActiveCard: some View { /* 調理セッション */ }
    @ViewBuilder private var helperTimerCompactCard: some View { /* 補助タイマー */ }
}
```

#### RecipeListView.swift
```swift
struct RecipeListView: View {
    // Core Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(...) private var recipes: FetchedResults<Recipe>
    
    // State
    @State private var searchText = ""
    @State private var selectedCategory = "全て"
    @State private var selectedRecipe: Recipe? = nil
    
    // Computed Properties
    private var filteredRecipes: [Recipe] { /* 検索・フィルター結果 */ }
    
    // CRUD Operations
    private func deleteRecipes(offsets: IndexSet) { /* レシピ削除 */ }
    
    // View Components
    @ViewBuilder private var searchSection: some View { /* 検索バー */ }
    @ViewBuilder private var categorySection: some View { /* カテゴリフィルター */ }
    @ViewBuilder private var recipeListSection: some View { /* レシピ一覧 */ }
}

struct CoreDataRecipeRowView: View {
    let recipe: Recipe
    let onTap: () -> Void
    @State private var isShowingEditSheet = false
    
    // レシピ行の表示・編集ボタン
}
```

#### CookingCompletionView.swift
```swift
struct CookingCompletionView: View {
    // Properties
    let recipe: Recipe
    let cookingRecord: CookingSessionRecord
    let user: User?
    let onComplete: (CookingRecord) -> Void
    
    // State
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var notes = ""
    @State private var isShowingLevelUpAnimation = false
    @State private var earnedBadges: [BadgeType] = []
    
    // Methods
    private func loadSelectedPhotos() { /* PhotosPicker結果処理 */ }
    private func saveBasicRecord() { /* 基本記録保存 */ }
    private func saveCompletionRecord() { /* 完全記録保存 */ }
    private func createCookingRecord() -> CookingRecord { /* レコード作成 */ }
    private func savePhotos() -> [String] { /* 写真保存 */ }
    private func checkForBadges() { /* バッジチェック */ }
    
    // View Components
    @ViewBuilder private var completionHeaderSection: some View { /* 完了ヘッダー */ }
    @ViewBuilder private var photoSection: some View { /* 写真セクション */ }
    @ViewBuilder private var notesSection: some View { /* メモセクション */ }
    @ViewBuilder private var experienceSection: some View { /* 経験値セクション */ }
}
```

## 🎨 アニメーション・演出

### LevelUpAnimationView.swift
```swift
struct LevelUpAnimationView: View {
    let newLevel: Int
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var sparkleRotation: Double = 0
    
    // 3秒間のスケール・フェード・回転アニメーション
}
```

### BadgeAcquisitionView.swift
```swift
struct BadgeAcquisitionView: View {
    let badges: [BadgeType]
    let onComplete: () -> Void
    
    // バッジ獲得演出（実装省略）
}
```

## 📱 ナビゲーション・状態管理

### ContentView.swift
```swift
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView { SimpleHomeView() }
                .tabItem { /* ホームタブ */ }
            
            RecipeListView()
                .tabItem { /* レシピタブ */ }
            
            HistoryStatsView()
                .tabItem { /* 履歴タブ */ }
        }
        .accentColor(.brown)
    }
}
```

## 🔄 データフロー

### Recipe Management Flow
```
User Input → AddRecipeView → Core Data → @FetchRequest → RecipeListView
```

### Cooking Session Flow
```
Recipe Selection → CookingSessionView → Timer Start → 
Completion → CookingCompletionView → Photo/Memo → 
Core Data Save → Experience/Badge Update → Animation
```

### Badge System Flow
```
Cooking Completion → BadgeSystem.checkBadges() → 
New Badges → Core Data Save → Badge Animation
```

## 📊 Performance Considerations

### Core Data最適化
```swift
// @FetchRequest with sortDescriptors
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
    animation: .default
) private var recipes: FetchedResults<Recipe>

// Predicate filtering
NSPredicate(format: "category == %@", "食事")
```

### メモリ管理
```swift
// ObservableObject lifecycle
@StateObject: View生成時に作成、View破棄時に解放
@ObservedObject: 外部から注入、親が管理

// Timer management
deinit {
    timer?.invalidate()
    timer = nil
}
```

## 🧪 テスト可能性

### Preview対応
```swift
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
            .environment(\.managedObjectContext, 
                         PersistenceController.preview.container.viewContext)
    }
}
```

### Mock Data
```swift
// PersistenceController.preview
static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    // テスト用データ作成
    return result
}()
```

## 🔧 設定・環境

### Info.plist設定
```xml
<!-- Camera Usage -->
<key>NSCameraUsageDescription</key>
<string>調理完了時の写真撮影に使用します</string>

<!-- Photo Library Usage -->
<key>NSPhotoLibraryUsageDescription</key>
<string>調理記録用の写真選択に使用します</string>
```

### Capabilities
- Background Modes: Background App Refresh
- Push Notifications: Local Notifications

---

**API設計完了日**: 2025年6月15日  
**設計者**: Claude Code  
**バージョン**: 1.0.0