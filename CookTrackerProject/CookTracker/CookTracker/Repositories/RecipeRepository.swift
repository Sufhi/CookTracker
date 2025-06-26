
//
//  RecipeRepository.swift
//  CookTracker
//
//  Created by Tsubasa Kubota on 2025/06/26.
//

import Foundation
import CoreData

protocol RecipeRepositoryProtocol {
    func fetchRecipes() -> [Recipe]
    func delete(recipe: Recipe)
    func saveContext()
}

class RecipeRepository: RecipeRepositoryProtocol {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func fetchRecipes() -> [Recipe] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch recipes: \(error)")
            return []
        }
    }
    
    func delete(recipe: Recipe) {
        viewContext.delete(recipe)
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
