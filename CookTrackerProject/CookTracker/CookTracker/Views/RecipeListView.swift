// MARK: - Imports
import SwiftUI
import CoreData

/// レシピ一覧を表示するメインビュー
/// - レシピの検索・フィルター機能を提供
/// - タップでレシピ詳細画面に遷移
struct RecipeListView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = RecipeListViewModel()
    @State private var isShowingAddRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                SearchBarView(text: $viewModel.searchText)
                
                // カテゴリフィルター
                CategoryFilterView(categories: viewModel.categories, selectedCategory: $viewModel.selectedCategory)
                
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
    
    
    
    @ViewBuilder
    private var recipeListSection: some View {
        if viewModel.filteredRecipes.isEmpty {
            EmptyRecipeView(onAddRecipe: {
                isShowingAddRecipe = true
            })
        } else {
            List {
                ForEach(viewModel.filteredRecipes, id: \.id) { recipe in
                    CoreDataRecipeRowView(recipe: recipe) {
                        selectedRecipe = recipe
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}