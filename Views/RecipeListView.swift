// MARK: - Imports
import SwiftUI

/// レシピ一覧を表示するメインビュー
/// - レシピの検索・フィルター機能を提供
/// - タップでレシピ詳細画面に遷移
struct RecipeListView: View {
    
    // MARK: - Properties
    @State private var searchText = ""
    @State private var selectedCategory = "全て"
    @State private var isShowingAddRecipe = false
    @State private var selectedRecipe: SampleRecipe? = nil
    @State private var recipes: [SampleRecipe] = [
        SampleRecipe(
            id: UUID(),
            title: "簡単オムライス",
            ingredients: "卵 2個\nご飯 200g\nケチャップ 大さじ2\n玉ねぎ 1/4個\nベーコン 2枚",
            instructions: "1. 玉ねぎとベーコンを炒める\n2. ご飯を加えてケチャップで味付け\n3. 卵でふわふわに包む",
            category: "食事",
            difficulty: 2,
            estimatedTime: 20,
            createdAt: Date()
        ),
        SampleRecipe(
            id: UUID(),
            title: "基本の味噌汁",
            ingredients: "味噌 大さじ1\nだしの素 小さじ1\n豆腐 1/4丁\nわかめ 適量",
            instructions: "1. 水400mlを沸騰させる\n2. だしの素を入れる\n3. 豆腐とわかめを加える\n4. 味噌を溶かす",
            category: "食事",
            difficulty: 1,
            estimatedTime: 10,
            createdAt: Date()
        ),
        SampleRecipe(
            id: UUID(),
            title: "チキンカレー",
            ingredients: "鶏肉 300g\n玉ねぎ 1個\nカレールー 1/2箱\nじゃがいも 2個\nにんじん 1本",
            instructions: "1. 野菜を切る\n2. 鶏肉を炒める\n3. 野菜を炒める\n4. 水を加えて煮込む\n5. カレールーを溶かす",
            category: "食事",
            difficulty: 3,
            estimatedTime: 45,
            createdAt: Date()
        ),
        SampleRecipe(
            id: UUID(),
            title: "フルーツサラダ",
            ingredients: "りんご 1個\nバナナ 1本\nオレンジ 1個\nヨーグルト 大さじ2\nはちみつ 小さじ1",
            instructions: "1. フルーツを一口大に切る\n2. ボウルに入れて混ぜる\n3. ヨーグルトとはちみつを加える",
            category: "デザート",
            difficulty: 1,
            estimatedTime: 10,
            createdAt: Date()
        )
    ]
    
    private let categories = ["全て", "食事", "デザート", "おつまみ"]
    
    // MARK: - Computed Properties
    private var filteredRecipes: [SampleRecipe] {
        let categoryFiltered = selectedCategory == "全て" ? recipes : recipes.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                searchSection
                
                // カテゴリフィルター
                categorySection
                
                // レシピ一覧
                recipeListSection
            }
            .navigationTitle("レシピ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddRecipe) {
                AddRecipeFormView { newRecipe in
                    recipes.append(newRecipe)
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("レシピを検索...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .foregroundColor(selectedCategory == category ? .white : .brown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.brown : Color.brown.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var recipeListSection: some View {
        if filteredRecipes.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピが見つかりません")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("新しいレシピを追加してください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("レシピを追加") {
                    isShowingAddRecipe = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        } else {
            List(filteredRecipes) { recipe in
                RecipeRowView(recipe: recipe) {
                    selectedRecipe = recipe
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// MARK: - Recipe Row View
struct RecipeRowView: View {
    let recipe: SampleRecipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // レシピ画像プレースホルダー
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brown.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 24))
                            .foregroundColor(.brown.opacity(0.6))
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(recipe.estimatedTime)分", systemImage: "clock")
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < recipe.difficulty ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(index < recipe.difficulty ? .brown : .gray.opacity(0.3))
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(recipe.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.brown)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brown.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sample Recipe Model
struct SampleRecipe: Identifiable {
    let id: UUID
    let title: String
    let ingredients: String
    let instructions: String
    let category: String
    let difficulty: Int
    let estimatedTime: Int
    let createdAt: Date
}

// MARK: - Add Recipe View
struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("この機能は次のステップで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: SampleRecipe
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cookingSession = CookingSessionTimer()
    @State private var isShowingCookingView = false
    @State private var completedRecord: CookingSessionRecord?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(recipe.estimatedTime)分", systemImage: "clock")
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("難易度:")
                                ForEach(0..<5) { index in
                                    Image(systemName: index < recipe.difficulty ? "star.fill" : "star")
                                        .foregroundColor(index < recipe.difficulty ? .brown : .gray.opacity(0.3))
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("材料")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.ingredients)
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作り方")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.instructions)
                            .font(.body)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("レシピ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(cookingSession.isRunning ? "調理中" : "調理開始") {
                        if !cookingSession.isRunning {
                            isShowingCookingView = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(cookingSession.isRunning ? .orange : .brown)
                    .disabled(cookingSession.isRunning)
                }
            }
            .sheet(isPresented: $isShowingCookingView) {
                CookingSessionView(
                    recipe: recipe,
                    cookingSession: cookingSession,
                    helperTimer: nil
                ) { record in
                    completedRecord = record
                    // 将来: Core Dataに保存
                    print("✅ 調理記録保存: \(record.formattedActualTime)")
                }
            }
        }
    }
}

// MARK: - Simple Add Recipe View
struct SimpleAddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var ingredients = ""
    @State private var category = "食事"
    
    let onRecipeAdded: (SampleRecipe) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("レシピ名", text: $title)
                    
                    Picker("カテゴリ", selection: $category) {
                        Text("食事").tag("食事")
                        Text("デザート").tag("デザート")
                        Text("おつまみ").tag("おつまみ")
                    }
                }
                
                Section("材料") {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("レシピを追加") {
                        let newRecipe = SampleRecipe(
                            id: UUID(),
                            title: title,
                            ingredients: ingredients,
                            instructions: "",
                            category: category,
                            difficulty: 2,
                            estimatedTime: 20,
                            createdAt: Date()
                        )
                        onRecipeAdded(newRecipe)
                        dismiss()
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
            }
            .navigationTitle("レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}