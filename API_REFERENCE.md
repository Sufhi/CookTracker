# CookTracker API リファレンス

**バージョン:** v0.3A  
**更新日:** 2025年6月14日

## 📚 主要クラス・構造体

### 1. CookingTimer クラス

```swift
class CookingTimer: ObservableObject
```

**概要:** 調理タイマーのロジックを管理するメインクラス

#### プロパティ

```swift
// Published Properties (UI自動更新)
@Published var timeRemaining: TimeInterval    // 残り時間（秒）
@Published var initialTime: TimeInterval     // 初期設定時間（秒）
@Published var isRunning: Bool              // 実行中フラグ
@Published var isFinished: Bool             // 完了フラグ

// Computed Properties (読み取り専用)
var progress: Double                        // 進捗率 (0.0-1.0)
var formattedTime: String                   // フォーマット済み時間表示 "MM:SS"
var progressPercentage: Int                 // 進捗パーセンテージ (0-100)
```

#### メソッド

```swift
// 基本操作
func startTimer(duration: TimeInterval)     // タイマー開始
func stopTimer()                           // タイマー停止
func pauseTimer()                          // タイマー一時停止
func resumeTimer()                         // タイマー再開
func resetTimer()                          // タイマーリセット

// クイック設定
func setQuickTime(minutes: Int)            // 分単位での時間設定
```

#### 使用例

```swift
@StateObject private var timer = CookingTimer()

// 20分タイマーを開始
timer.startTimer(duration: 20 * 60)

// クイック設定（10分）
timer.setQuickTime(minutes: 10)

// 進捗表示
Text("進捗: \(timer.progressPercentage)%")
ProgressView(value: timer.progress)
```

### 2. SampleRecipe 構造体

```swift
struct SampleRecipe: Identifiable
```

**概要:** レシピデータを表現する構造体

#### プロパティ

```swift
let id: UUID                    // 一意識別子
let title: String              // レシピタイトル
let ingredients: String        // 材料（改行区切り文字列）
let instructions: String       // 手順（改行区切り文字列）
let category: String          // カテゴリ（"食事", "デザート", "おつまみ"）
let difficulty: Int           // 難易度（1-5）
let estimatedTime: Int        // 予想調理時間（分）
let createdAt: Date          // 作成日時
```

#### 使用例

```swift
let recipe = SampleRecipe(
    id: UUID(),
    title: "簡単オムライス",
    ingredients: "卵 2個\nご飯 200g\nケチャップ 大さじ2",
    instructions: "1. 卵を溶く\n2. フライパンで焼く\n3. ご飯を包む",
    category: "食事",
    difficulty: 2,
    estimatedTime: 20,
    createdAt: Date()
)
```

## 🖼 主要ビュー

### 1. CookingTimerView

```swift
struct CookingTimerView: View
```

**概要:** 調理タイマーのメインUI

#### 主要機能
- 円形プログレス表示
- クイック時間設定ボタン
- カスタム時間ピッカー
- 再生/停止/リセットコントロール

#### 状態管理

```swift
@StateObject private var timer = CookingTimer()
@State private var selectedMinutes = 10
@State private var showingTimePicker = false
@State private var showingCompletionView = false
```

### 2. RecipeListView

```swift
struct RecipeListView: View
```

**概要:** レシピ一覧表示とフィルタリング機能

#### 主要機能
- レシピ検索（タイトル・材料）
- カテゴリフィルタリング
- レシピ追加・詳細表示

#### 状態管理

```swift
@State private var searchText = ""
@State private var selectedCategory = "全て"
@State private var recipes: [SampleRecipe] = [...]
```

### 3. SimpleHomeView

```swift
struct SimpleHomeView: View
```

**概要:** アプリのホーム画面

#### 主要セクション
- ユーザー情報・レベル表示
- 今日の調理提案
- クイックアクションボタン
- 最近の料理履歴

## 🔧 ユーティリティ・拡張

### 通知機能

```swift
// CookingTimer内の通知メソッド
private func scheduleNotification(duration: TimeInterval)
private func cancelNotification()
private func sendCompletionNotification()
```

#### 通知設定例

```swift
// アプリ起動時（CookTrackersApp.swift）
private func setupNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        // 処理
    }
}
```

### バックグラウンドタスク

```swift
// CookingTimer内のバックグラウンド処理
private func startBackgroundTask()
private func endBackgroundTask()

// UIBackgroundTaskIdentifierを使用
private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
```

## 📱 画面遷移パターン

### Sheet Navigation（モーダル表示）

```swift
// レシピ追加
.sheet(isPresented: $isShowingAddRecipe) {
    AddRecipeFormView { newRecipe in
        recipes.append(newRecipe)
    }
}

// タイマー表示
.sheet(isPresented: $isShowingTimer) {
    CookingTimerView()
}

// 時間設定
.sheet(isPresented: $showingTimePicker) {
    TimePickerView(selectedMinutes: $selectedMinutes) {
        timer.setQuickTime(minutes: selectedMinutes)
    }
}
```

### TabView Navigation

```swift
TabView {
    SimpleHomeView()
        .tabItem {
            Image(systemName: "house.fill")
            Text("ホーム")
        }
    
    RecipeListView()
        .tabItem {
            Image(systemName: "book.fill")
            Text("レシピ")
        }
    
    // その他のタブ...
}
```

## 🎨 スタイリング・テーマ

### カラーテーマ

```swift
// メインカラー
.foregroundColor(.brown)           // プライマリーカラー
.tint(.brown)                     // アクセントカラー

// 背景・セカンダリー
.background(Color.brown.opacity(0.1))    // 薄いブラウン背景
.foregroundColor(.secondary)             // セカンダリーテキスト
```

### よく使用されるスタイル

```swift
// ボタンスタイル
.buttonStyle(.borderedProminent)
.controlSize(.large)
.tint(.brown)

// カードスタイル
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
)

// プログレスサークル
Circle()
    .trim(from: 0, to: timer.progress)
    .stroke(Color.brown, style: StrokeStyle(lineWidth: 8, lineCap: .round))
    .rotationEffect(.degrees(-90))
    .animation(.easeInOut(duration: 1), value: timer.progress)
```

## 🚀 使用例とベストプラクティス

### タイマー機能の実装例

```swift
struct MyTimerView: View {
    @StateObject private var timer = CookingTimer()
    
    var body: some View {
        VStack {
            // 時間表示
            Text(timer.formattedTime)
                .font(.largeTitle)
            
            // プログレス表示
            ProgressView(value: timer.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .brown))
            
            // コントロールボタン
            Button(timer.isRunning ? "停止" : "開始") {
                if timer.isRunning {
                    timer.pauseTimer()
                } else {
                    timer.resumeTimer()
                }
            }
        }
        .onChange(of: timer.isFinished) { isFinished in
            if isFinished {
                // 完了処理
            }
        }
    }
}
```

### レシピフィルタリングの実装例

```swift
private var filteredRecipes: [SampleRecipe] {
    let categoryFiltered = selectedCategory == "全て" 
        ? recipes 
        : recipes.filter { $0.category == selectedCategory }
    
    return searchText.isEmpty 
        ? categoryFiltered
        : categoryFiltered.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(searchText) ||
            recipe.ingredients.localizedCaseInsensitiveContains(searchText)
        }
}
```

## 📋 エラーハンドリング

### 通知権限エラー

```swift
UNUserNotificationCenter.current().requestAuthorization(...) { granted, error in
    if let error = error {
        print("❌ 通知権限エラー: \(error.localizedDescription)")
    }
}
```

### タイマー状態エラー

```swift
func startTimer(duration: TimeInterval) {
    guard duration > 0 else { 
        print("⚠️ 無効な時間が設定されました")
        return 
    }
    // タイマー開始処理
}
```

---

**📝 注意:** このAPIリファレンスは現在の実装に基づいています。Core Data統合後は大幅に変更される予定です。