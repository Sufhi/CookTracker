// MARK: - Imports
import Foundation

/// サンプルレシピモデル
/// - メモリ上でのレシピデータ表現
/// - Core Dataレシピとの変換に使用
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