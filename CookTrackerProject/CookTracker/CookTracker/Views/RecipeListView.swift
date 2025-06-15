// MARK: - Imports
import SwiftUI
import CoreData

/// レシピ一覧を表示するメインビュー
/// - レシピの検索・フィルター機能を提供
/// - タップでレシピ詳細画面に遷移
struct RecipeListView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedCategory = "全て"
    @State private var isShowingAddRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    
    // Core Data取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    private let categories = ["全て", "食事", "デザート", "おつまみ"]
    
    // MARK: - Computed Properties
    private var filteredRecipes: [Recipe] {
        let allRecipes = Array(recipes)
        let categoryFiltered = selectedCategory == "全て" ? allRecipes : allRecipes.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { recipe in
                (recipe.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                (recipe.ingredients ?? "").localizedCaseInsensitiveContains(searchText)
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
                CoreDataAddRecipeView()
            }
            .sheet(item: $selectedRecipe) { recipe in
                CoreDataRecipeDetailView(recipe: recipe)
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
            List {
                ForEach(filteredRecipes, id: \.id) { recipe in
                    CoreDataRecipeRowView(recipe: recipe) {
                        selectedRecipe = recipe
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    // MARK: - Methods
    
    /// レシピ削除
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            PersistenceController.shared.save()
        }
    }
}

// MARK: - Core Data Recipe Row View
struct CoreDataRecipeRowView: View {
    let recipe: Recipe
    let onTap: () -> Void
    @State private var isShowingEditSheet = false
    
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
                    Text(recipe.title ?? "無題のレシピ")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(Int(recipe.estimatedTimeInMinutes))分", systemImage: "clock")
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(recipe.difficulty) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(index < Int(recipe.difficulty) ? .brown : .gray.opacity(0.3))
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(recipe.category ?? "食事")
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
                
                // 編集ボタン
                Button(action: {
                    isShowingEditSheet = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingEditSheet) {
            CoreDataEditRecipeView(recipe: recipe)
        }
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

// MARK: - Core Data Add Recipe View
struct CoreDataAddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var category = "食事"
    @State private var difficulty: Double = 2
    @State private var estimatedTime: Double = 20
    @State private var url = ""
    
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
                    
                    VStack(alignment: .leading) {
                        Text("難易度: \(Int(difficulty))")
                        Slider(value: $difficulty, in: 1...5, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("予想時間: \(Int(estimatedTime))分")
                        Slider(value: $estimatedTime, in: 5...120, step: 5)
                    }
                }
                
                Section("材料") {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 100)
                }
                
                Section("作り方") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
                
                Section("URL（任意）") {
                    TextField("レシピのURL", text: $url)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button("レシピを追加") {
                        saveRecipe()
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
    
    private func saveRecipe() {
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.title = title
        newRecipe.ingredients = ingredients
        newRecipe.instructions = instructions
        newRecipe.category = category
        newRecipe.difficulty = Int32(difficulty)
        newRecipe.estimatedTimeInMinutes = Int32(estimatedTime)
        newRecipe.url = url.isEmpty ? nil : url
        newRecipe.createdAt = Date()
        newRecipe.updatedAt = Date()
        
        PersistenceController.shared.save()
        dismiss()
    }
}

// MARK: - Core Data Edit Recipe View
struct CoreDataEditRecipeView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String
    @State private var ingredients: String
    @State private var instructions: String
    @State private var category: String
    @State private var difficulty: Double
    @State private var estimatedTime: Double
    @State private var url: String
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title ?? "")
        _ingredients = State(initialValue: recipe.ingredients ?? "")
        _instructions = State(initialValue: recipe.instructions ?? "")
        _category = State(initialValue: recipe.category ?? "食事")
        _difficulty = State(initialValue: Double(recipe.difficulty))
        _estimatedTime = State(initialValue: Double(recipe.estimatedTimeInMinutes))
        _url = State(initialValue: recipe.url ?? "")
    }
    
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
                    
                    VStack(alignment: .leading) {
                        Text("難易度: \(Int(difficulty))")
                        Slider(value: $difficulty, in: 1...5, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("予想時間: \(Int(estimatedTime))分")
                        Slider(value: $estimatedTime, in: 5...120, step: 5)
                    }
                }
                
                Section("材料") {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 100)
                }
                
                Section("作り方") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
                
                Section("URL（任意）") {
                    TextField("レシピのURL", text: $url)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button("変更を保存") {
                        saveRecipe()
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
            }
            .navigationTitle("レシピ編集")
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
    
    private func saveRecipe() {
        recipe.title = title
        recipe.ingredients = ingredients
        recipe.instructions = instructions
        recipe.category = category
        recipe.difficulty = Int32(difficulty)
        recipe.estimatedTimeInMinutes = Int32(estimatedTime)
        recipe.url = url.isEmpty ? nil : url
        recipe.updatedAt = Date()
        
        PersistenceController.shared.save()
        dismiss()
    }
}

// MARK: - Core Data Recipe Detail View
struct CoreDataRecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cookingSession = CookingSessionTimer()
    @State private var isShowingCookingView = false
    @State private var isShowingEditView = false
    @State private var currentUser: User?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title ?? "無題のレシピ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(Int(recipe.estimatedTimeInMinutes))分", systemImage: "clock")
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("難易度:")
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(recipe.difficulty) ? "star.fill" : "star")
                                        .foregroundColor(index < Int(recipe.difficulty) ? .brown : .gray.opacity(0.3))
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(recipe.category ?? "食事")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.brown)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.brown.opacity(0.1))
                            )
                    }
                    
                    Divider()
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("材料")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.ingredients ?? "材料なし")
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作り方")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.instructions ?? "手順なし")
                            .font(.body)
                    }
                    
                    // URL（ある場合）
                    if let urlString = recipe.url, !urlString.isEmpty, let url = URL(string: urlString) {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("参考URL")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Link(urlString, destination: url)
                                .font(.body)
                                .foregroundColor(.blue)
                        }
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
                CoreDataCookingSessionView(
                    recipe: recipe,
                    cookingSession: cookingSession,
                    helperTimer: nil,
                    user: currentUser
                ) { record in
                    print("✅ 調理記録保存: \(record.formattedCookingTime)")
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                CoreDataEditRecipeView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("編集", action: {
                            isShowingEditView = true
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                currentUser = PersistenceController.shared.getOrCreateDefaultUser()
            }
        }
    }
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
