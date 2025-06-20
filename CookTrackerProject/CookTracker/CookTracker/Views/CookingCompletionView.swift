// MARK: - Imports
import SwiftUI
import PhotosUI
import CoreData

/// 調理完了時の記録画面
/// - 写真撮影・選択機能
/// - メモ入力機能  
/// - 経験値獲得表示
/// - Core Data保存
struct CookingCompletionView: View {
    
    // MARK: - Properties
    let recipe: Recipe
    let cookingRecord: CookingSessionRecord
    let user: User?
    let onComplete: (CookingRecord) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // UI State
    @State private var photoImages: [UIImage] = []
    @State private var notes = ""
    @State private var isShowingLevelUpAnimation = false
    @State private var leveledUp = false
    @State private var newLevel: Int = 1
    @State private var experienceGained: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 完了ヘッダー
                    completionHeaderSection
                    
                    // 調理時間表示
                    cookingTimeSection
                    
                    // 写真セクション
                    PhotoManagementView(photoImages: $photoImages)
                    
                    // メモセクション
                    notesSection
                    
                    // 経験値・レベル表示
                    experienceSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("調理完了")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("後で") {
                        saveBasicRecord()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveCompletionRecord()
                    }
                    .fontWeight(.semibold)
                    .disabled(photoImages.isEmpty && notes.isEmpty)
                }
            }
            .overlay {
                if isShowingLevelUpAnimation {
                    LevelUpAnimationView(
                        newLevel: newLevel,
                        onComplete: {
                            isShowingLevelUpAnimation = false
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var completionHeaderSection: some View {
        VStack(spacing: 16) {
            // 完了アイコン
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("調理完了！")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(recipe.title ?? "レシピ")
                    .font(.headline)
                    .foregroundColor(.brown)
                
                Text("お疲れさまでした🍴")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var cookingTimeSection: some View {
        VStack(spacing: 12) {
            Text("調理時間")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("実際の時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(cookingRecord.formattedActualTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("予想時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(recipe.estimatedTimeInMinutes))分")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGroupedBackground))
        )
    }
    
    @ViewBuilder
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("改善メモ")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("次回作るときの参考になるメモを記録してください")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var experienceSection: some View {
        VStack(spacing: 16) {
            Text("獲得経験値")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("基本経験値")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("+\(experienceGained) XP")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
                
                Spacer()
                
                if leveledUp {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("レベルアップ！")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("Lv.\(newLevel)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if let user = user {
                VStack(spacing: 8) {
                    HStack {
                        Text("現在のレベル: \(Int(user.level))")
                        Spacer()
                        Text("経験値: \(Int(user.experiencePoints)) XP")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    ProgressView(value: user.progressToNextLevel, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brown.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            initializeExperience()
        }
    }
    
    // MARK: - Methods
    
    /// 経験値の初期表示を設定
    private func initializeExperience() {
        experienceGained = ExperienceService.shared.calculateExperience(for: recipe)
    }
    
    
    /// 基本記録のみ保存（写真・メモなし）
    private func saveBasicRecord() {
        let record = createCookingRecord()
        onComplete(record)
        dismiss()
    }
    
    /// 完全な記録を保存（写真・メモ含む）
    private func saveCompletionRecord() {
        let hasPhotos = !photoImages.isEmpty
        let hasNotes = !notes.isEmpty
        
        // ExperienceServiceを使用して記録作成と経験値付与を一括処理
        let (record, didLevelUp, actualExperience) = ExperienceService.shared.createCookingRecordWithExperience(
            context: viewContext,
            recipe: recipe,
            cookingTime: cookingRecord.actualMinutes,
            hasPhotos: hasPhotos,
            hasNotes: hasNotes,
            user: user
        )
        
        // 実際の経験値を更新
        experienceGained = actualExperience
        
        // 写真を保存
        if hasPhotos {
            let photoPaths = savePhotos()
            record.photoPaths = photoPaths as NSObject
        }
        
        // メモを保存
        if hasNotes {
            record.notes = notes
        }
        
        // レベルアップ処理
        if didLevelUp {
            leveledUp = true
            newLevel = Int(user?.level ?? 1)
            // レベルアップアニメーション表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShowingLevelUpAnimation = true
            }
        }
        
        PersistenceController.shared.save()
        onComplete(record)
        
        // アニメーション表示されない場合は即座に閉じる
        if !leveledUp {
            dismiss()
        } else {
            // レベルアップアニメーション後に閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        }
    }
    
    /// CookingRecord作成
    private func createCookingRecord() -> CookingRecord {
        let record = CookingRecord(context: viewContext)
        record.id = UUID()
        record.recipeId = recipe.id
        record.cookingTimeInMinutes = Int32(cookingRecord.actualMinutes)
        record.experienceGained = Int32(experienceGained)
        record.cookedAt = Date()
        record.recipe = recipe
        return record
    }
    
    /// 写真保存処理
    private func savePhotos() -> [String] {
        var photoPaths: [String] = []
        
        for (index, uiImage) in photoImages.enumerated() {
            let imageName = "\(recipe.id?.uuidString ?? "unknown")_\(index)_\(Date().timeIntervalSince1970).jpg"
            
            if let imageData = uiImage.jpegData(compressionQuality: 0.8) {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageURL = documentsDirectory.appendingPathComponent(imageName)
                
                do {
                    try imageData.write(to: imageURL)
                    photoPaths.append(imageName)
                    AppLogger.success("画像保存成功: \(imageName)")
                } catch {
                    AppLogger.error("画像保存エラー", error: error)
                }
            } else {
                AppLogger.error("画像データ変換エラー")
            }
        }
        
        return photoPaths
    }
    
}

// MARK: - Preview
struct CookingCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let recipe = Recipe(context: context)
        recipe.title = "サンプルレシピ"
        recipe.estimatedTimeInMinutes = 20
        
        let user = User(context: context)
        user.level = 2
        user.experiencePoints = 200
        
        let record = CookingSessionRecord(
            startTime: Date().addingTimeInterval(-1500),
            endTime: Date(),
            elapsedTime: 1500,
            pausedDuration: 0,
            actualCookingTime: 1500
        )
        
        return CookingCompletionView(
            recipe: recipe,
            cookingRecord: record,
            user: user
        ) { _ in
            AppLogger.success("調理完了記録保存")
        }
    }
}
