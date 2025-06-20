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
                RecipeFormView()
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

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}