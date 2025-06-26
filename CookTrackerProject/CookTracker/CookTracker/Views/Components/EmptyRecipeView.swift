
//
//  EmptyRecipeView.swift
//  CookTracker
//
//  Created by Tsubasa Kubota on 2025/06/26.
//

import SwiftUI

struct EmptyRecipeView: View {
    var onAddRecipe: () -> Void
    
    var body: some View {
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
                onAddRecipe()
            }
            .buttonStyle(.borderedProminent)
            .tint(.brown)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct EmptyRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyRecipeView(onAddRecipe: {}) // ダミーのクロージャを渡す
            .previewLayout(.sizeThatFits)
    }
}
