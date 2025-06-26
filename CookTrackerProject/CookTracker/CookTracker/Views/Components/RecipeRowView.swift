//
//  RecipeRowView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI
import CoreData

/// レシピ一覧の行コンポーネント
/// - レシピ情報を統一されたレイアウトで表示
/// - サムネイル、タイトル、時間、難易度、カテゴリを含む
struct CoreDataRecipeRowView: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // レシピ画像またはプレースホルダー
                Group {
                    if let thumbnailImage = recipe.thumbnailImage {
                        Image(uiImage: thumbnailImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 24))
                                    .foregroundColor(.brown.opacity(0.6))
                            )
                    }
                }
                
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
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct CoreDataRecipeRowView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataRecipeRowView(recipe: {
            let context = PersistenceController.preview.container.viewContext
            let recipe = Recipe(context: context)
            recipe.title = "簡単オムライス"
            recipe.estimatedTimeInMinutes = 20
            recipe.difficulty = 2
            recipe.category = "食事"
            return recipe
        }()) {
            print("Recipe tapped")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}