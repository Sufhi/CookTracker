
//
//  RecipeListViewModel.swift
//  CookTracker
//
//  Created by Tsubasa Kubota on 2025/06/26.
//

import Foundation
import CoreData
import Combine

class RecipeListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory = "全て"
    @Published var recipes: [Recipe] = []
    
    private let recipeRepository: RecipeRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    let categories = ["全て", "食事", "デザート", "おつまみ"]
    
    init(recipeRepository: RecipeRepositoryProtocol = RecipeRepository(context: PersistenceController.shared.container.viewContext)) {
        self.recipeRepository = recipeRepository
        fetchRecipes()
        
        // searchTextまたはselectedCategoryが変更されたらレシピをフィルタリングする
        Publishers.CombineLatest($searchText, $selectedCategory)
            .map { [weak self] searchText, selectedCategory in
                self?.filterRecipes(searchText: searchText, selectedCategory: selectedCategory) ?? []
            }
            .assign(to: \.recipes, on: self)
            .store(in: &cancellables)
    }
    
    var filteredRecipes: [Recipe] {
        let allRecipes = recipes
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
    
    func fetchRecipes() {
        recipes = recipeRepository.fetchRecipes()
    }
    
    private func filterRecipes(searchText: String, selectedCategory: String) -> [Recipe] {
        let allRecipes = recipeRepository.fetchRecipes()
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
    
    func delete(at offsets: IndexSet) {
        offsets.map { filteredRecipes[$0] }.forEach(recipeRepository.delete)
    }
}
