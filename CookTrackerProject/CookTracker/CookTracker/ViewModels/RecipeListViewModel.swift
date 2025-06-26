
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
    
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    let categories = ["全て", "食事", "デザート", "おつまみ"]
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
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
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)]
        
        do {
            recipes = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch recipes: \(error)")
        }
    }
    
    private func filterRecipes(searchText: String, selectedCategory: String) -> [Recipe] {
        var filtered: [Recipe] = []
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)]
        
        do {
            let allRecipes = try viewContext.fetch(request)
            let categoryFiltered = selectedCategory == "全て" ? allRecipes : allRecipes.filter { $0.category == selectedCategory }
            
            if searchText.isEmpty {
                filtered = categoryFiltered
            } else {
                filtered = categoryFiltered.filter { recipe in
                    (recipe.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                    (recipe.ingredients ?? "").localizedCaseInsensitiveContains(searchText)
                }
            }
        } catch {
            print("Failed to fetch and filter recipes: \(error)")
        }
        return filtered
    }
    
    func delete(at offsets: IndexSet) {
        offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
