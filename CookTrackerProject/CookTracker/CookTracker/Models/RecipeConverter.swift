import Foundation

/// Core DataのRecipeをSampleRecipeに変換する責任を持つユーティリティ
/// 単一責任: データモデル間の変換
struct RecipeConverter {
    
    /// Core DataのRecipeをSampleRecipeに変換
    /// - Parameter recipe: Core DataのRecipeエンティティ
    /// - Returns: 変換されたSampleRecipe
    static func toSampleRecipe(_ recipe: Recipe) -> SampleRecipe {
        return SampleRecipe(
            id: recipe.id ?? UUID(),
            title: recipe.title ?? "無題のレシピ",
            ingredients: recipe.ingredients ?? "",
            instructions: recipe.instructions ?? "",
            category: recipe.category ?? "食事",
            difficulty: Int(recipe.difficulty),
            estimatedTime: Int(recipe.estimatedTimeInMinutes),
            createdAt: recipe.createdAt ?? Date()
        )
    }
}