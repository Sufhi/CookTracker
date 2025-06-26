//
//  RecipeFormView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI
import CoreData

/// レシピ作成・編集用の共通フォームコンポーネント
/// - レシピの基本情報入力フォーム
/// - 新規作成と編集の両方に対応
struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // フォーム状態
    @State var title: String
    @State var ingredients: String
    @State var instructions: String
    @State var category: String
    @State var difficulty: Double
    @State var estimatedTime: Double
    @State var url: String
    
    // 設定
    let isEditMode: Bool
    let recipe: Recipe?
    let onSave: (() -> Void)?
    
    // 初期化
    init(recipe: Recipe? = nil, onSave: (() -> Void)? = nil) {
        self.recipe = recipe
        self.isEditMode = recipe != nil
        self.onSave = onSave
        
        // 初期値設定
        _title = State(initialValue: recipe?.title ?? "")
        _ingredients = State(initialValue: recipe?.ingredients ?? "")
        _instructions = State(initialValue: recipe?.instructions ?? "")
        _category = State(initialValue: recipe?.category ?? "食事")
        _difficulty = State(initialValue: Double(recipe?.difficulty ?? 2))
        _estimatedTime = State(initialValue: Double(recipe?.estimatedTimeInMinutes ?? 20))
        _url = State(initialValue: recipe?.url ?? "")
    }
    
    private let categories = ["食事", "デザート", "おつまみ"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("レシピ名", text: $title)
                    
                    Picker("カテゴリ", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
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
                    Button(isEditMode ? "これでOK！" : "この内容で登録！") {
                        saveRecipe()
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
            }
            .navigationTitle(isEditMode ? "レシピ編集" : "レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("やめる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveRecipe() {
        if isEditMode, let recipe = recipe {
            // 編集モード
            recipe.title = title
            recipe.ingredients = ingredients
            recipe.instructions = instructions
            recipe.category = category
            recipe.difficulty = Int32(difficulty)
            recipe.estimatedTimeInMinutes = Int32(estimatedTime)
            recipe.url = url.isEmpty ? nil : url
            recipe.updatedAt = Date()
        } else {
            // 新規作成モード
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
            
            // Core Dataに先に保存
            PersistenceController.shared.save()
            
            // 新規レシピ登録時の経験値処理
            let experienceGained = processNewRecipeExperience(recipe: newRecipe)
            
            // 経験値通知をトリガー（レベルアップ判定は行わない）
            if experienceGained > 0 {
                ExperienceNotificationManager.shared.triggerExperienceNotification(
                    gained: experienceGained,
                    levelUp: false,
                    oldLv: 0,
                    newLv: 0
                )
            }
        }
        
        if isEditMode {
            PersistenceController.shared.save()
        }
        
        onSave?()
        dismiss()
    }
    
    /// 新規レシピ登録時の経験値処理
    /// - Parameter recipe: 新規作成されたレシピ
    /// - Returns: 獲得した経験値
    private func processNewRecipeExperience(recipe: Recipe) -> Int {
        var totalExperience = 0
        
        // レシピ登録ボーナス（1日1回制限）
        let registrationBonus = ExperienceService.shared.processRecipeRegistrationBonus(context: viewContext)
        totalExperience += registrationBonus
        
        // 難易度・カテゴリボーナス
        let enhancedExperience = ExperienceService.shared.calculateEnhancedExperience(
            context: viewContext,
            recipe: recipe,
            hasPhotos: false,
            hasNotes: !instructions.isEmpty,
            isNewRecipe: true
        )
        
        // 基本経験値は除いて、ボーナス分のみを追加
        let baseExperience = ExperienceService.shared.calculateExperience(
            for: recipe,
            hasPhotos: false,
            hasNotes: !instructions.isEmpty
        )
        let bonusOnly = enhancedExperience - baseExperience
        totalExperience += bonusOnly
        
        // ユーザーに経験値付与
        let user = PersistenceController.shared.getOrCreateDefaultUser()
        ExperienceService.shared.awardExperience(to: user, amount: totalExperience)
        PersistenceController.shared.save()
        
        return totalExperience
    }
}

// MARK: - Preview
struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFormView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}