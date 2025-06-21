// MARK: - Imports
import SwiftUI
import CoreData

/// Core Dataレシピの詳細表示画面
/// - レシピ情報の表示
/// - 調理開始・履歴管理
/// - サムネイル編集機能
struct CoreDataRecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var sessionManager: CookingSessionManager
    @State private var isShowingCookingView = false
    @State private var isShowingEditView = false
    @State private var currentUser: User?
    @State private var selectedCookingRecord: CookingRecord?
    @State private var isShowingFullHistory = false
    @State private var isShowingImagePicker = false
    @State private var selectedThumbnailImage: UIImage?
    
    // このレシピの調理記録を取得
    var cookingRecords: [CookingRecord] {
        guard let recipeId = recipe.id else { return [] }
        
        let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %@", recipeId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            AppLogger.coreDataError("調理履歴取得", error: error)
            return []
        }
    }
    
    // 改善メモのある調理記録を取得
    var improvementNotes: [CookingRecord] {
        return cookingRecords.filter { record in
            guard let notes = record.notes, !notes.isEmpty else { return false }
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 調理中の場合は調理中カード、そうでなければ調理開始ボタンを表示
                    if sessionManager.isCurrentlyCooking {
                        CookingSessionActiveCard(onSessionTap: {
                            isShowingCookingView = true
                        })
                    } else {
                        // 調理開始ボタン（おしゃれなデザイン）
                        Button(action: {
                            let _ = sessionManager.startCookingSession(for: recipe)
                            isShowingCookingView = true
                        }) {
                            HStack(spacing: 12) {
                                // アイコン
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                // テキスト
                                Text("調理を開始する")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // 右側のアイコン
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.brown]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.brown.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // ヘッダー情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title ?? "無題のレシピ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(Int(recipe.estimatedTimeInMinutes))分", systemImage: "clock")
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("難易度:")
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(recipe.difficulty) ? "star.fill" : "star")
                                        .foregroundColor(index < Int(recipe.difficulty) ? .brown : .gray.opacity(0.3))
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(recipe.category ?? "食事")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.brown)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.brown.opacity(0.1))
                            )
                    }
                    
                    Divider()
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("材料")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.ingredients ?? "材料なし")
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作り方")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.instructions ?? "手順なし")
                            .font(.body)
                    }
                    
                    // URL（ある場合）
                    if let urlString = recipe.url, !urlString.isEmpty, let url = URL(string: urlString) {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("参考URL")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Link(urlString, destination: url)
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("レシピ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingCookingView) {
                if let currentRecipe = sessionManager.currentRecipe,
                   let currentSession = sessionManager.currentSession {
                    CookingSessionView(
                        recipe: RecipeConverter.toSampleRecipe(currentRecipe),
                        cookingSession: currentSession,
                        onCookingComplete: { sampleRecord in
                            print("✅ 調理記録保存: \\(sampleRecord.formattedActualTime)")
                            sessionManager.finishCookingSession()
                        },
                        helperTimer: sessionManager.sharedHelperTimer
                    )
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                RecipeFormView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("編集", action: {
                            isShowingEditView = true
                        })
                        
                        Divider()
                        
                        Button("サムネイル選択", action: {
                            isShowingImagePicker = true
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                currentUser = PersistenceController.shared.getOrCreateDefaultUser()
            }
            .sheet(item: $selectedCookingRecord) { record in
                CookingRecordDetailView(cookingRecord: record)
            }
            .sheet(isPresented: $isShowingFullHistory) {
                RecipeCookingHistoryView(recipe: recipe)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(
                    selectedImage: $selectedThumbnailImage,
                    hasCurrentImage: recipe.hasThumbnail,
                    onSave: { image in
                        saveThumbnail(image)
                    }
                )
            }
        }
    }
    
    private func saveThumbnail(_ image: UIImage?) {
        if let image = image {
            // 画像を保存
            if recipe.saveThumbnailImage(image) {
                do {
                    try viewContext.save()
                    print("✅ サムネイル保存成功")
                } catch {
                    print("❌ サムネイル保存エラー: \\(error)")
                }
            }
        } else {
            // 画像を削除
            recipe.deleteThumbnailImage()
            do {
                try viewContext.save()
                print("✅ サムネイル削除成功")
            } catch {
                print("❌ サムネイル削除エラー: \\(error)")
            }
        }
        selectedThumbnailImage = nil
    }
}

// MARK: - Preview
struct CoreDataRecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let recipe = Recipe(context: context)
        recipe.title = "サンプルレシピ"
        recipe.ingredients = "材料1\n材料2"
        recipe.instructions = "手順1\n手順2"
        recipe.difficulty = 3
        recipe.estimatedTimeInMinutes = 30
        
        return CoreDataRecipeDetailView(recipe: recipe)
            .environment(\.managedObjectContext, context)
            .environmentObject(CookingSessionManager.shared)
    }
}