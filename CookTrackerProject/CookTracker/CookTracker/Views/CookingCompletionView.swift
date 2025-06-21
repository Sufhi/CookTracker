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
    @State private var isShowingExperienceAnimation = false
    @State private var experienceAnimationData: (gained: Int, didLevelUp: Bool, oldLevel: Int, newLevel: Int)?
    
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
                    
                    // 保存ボタン
                    saveButtonSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("調理完了")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("後で") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .fontWeight(.semibold)
                    .disabled(photoImages.isEmpty && notes.isEmpty)
                }
            }
            .fullScreenCover(isPresented: $isShowingExperienceAnimation) {
                if let animationData = experienceAnimationData {
                    ExperienceChangeAnimation(
                        experienceGained: animationData.gained,
                        didLevelUp: animationData.didLevelUp,
                        oldLevel: animationData.oldLevel,
                        newLevel: animationData.newLevel,
                        context: .cooking
                    ) {
                        isShowingExperienceAnimation = false
                        onComplete(createFinalCookingRecord())
                        dismiss()
                    }
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
    private var saveButtonSection: some View {
        VStack(spacing: 16) {
            // 保存ボタン
            Button(action: {
                saveRecord()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("調理記録を保存")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brown)
                )
            }
            
            // 後で保存ボタン
            Button(action: {
                dismiss()
            }) {
                Text("後で保存")
                    .font(.subheadline)
                    .foregroundColor(.brown)
            }
        }
        .padding()
    }
    
    // MARK: - Methods
    
    /// 調理記録を保存して経験値アニメーションを表示
    private func saveRecord() {
        guard let user = user else {
            // ユーザーがいない場合は直接保存
            onComplete(createFinalCookingRecord())
            dismiss()
            return
        }
        
        // 経験値計算
        let oldLevel = Int(user.level)
        let experienceGained = ExperienceService.shared.calculateExperience(
            for: nil,
            hasPhotos: !photoImages.isEmpty,
            hasNotes: !notes.isEmpty
        )
        
        // 経験値付与とレベルアップ判定
        let didLevelUp = user.addExperience(Int32(experienceGained))
        let newLevel = Int(user.level)
        
        // Core Data保存
        PersistenceController.shared.save()
        
        // アニメーションデータを設定
        experienceAnimationData = (
            gained: experienceGained,
            didLevelUp: didLevelUp,
            oldLevel: oldLevel,
            newLevel: newLevel
        )
        
        // 経験値アニメーション表示
        isShowingExperienceAnimation = true
    }
    
    /// 最終的なCookingRecord作成
    private func createFinalCookingRecord() -> CookingRecord {
        let record = CookingRecord(context: viewContext)
        record.id = UUID()
        record.recipe = recipe
        record.recipeId = recipe.id
        record.cookingTimeInMinutes = Int32(cookingRecord.actualMinutes)
        record.experienceGained = Int32(ExperienceService.shared.calculateExperience(
            for: nil,
            hasPhotos: !photoImages.isEmpty,
            hasNotes: !notes.isEmpty
        ))
        record.cookedAt = cookingRecord.endTime
        record.notes = notes.isEmpty ? nil : notes
        record.photoPaths = savePhotoImages() as NSObject
        
        return record
    }
    
    /// 写真を保存してパスを返す
    private func savePhotoImages() -> [String] {
        var photoPaths: [String] = []
        
        for (index, image) in photoImages.enumerated() {
            let fileName = "\(UUID().uuidString)_\(index).jpg"
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    try? imageData.write(to: fileURL)
                    photoPaths.append(fileName)
                }
            }
        }
        
        return photoPaths
    }
    
    /// 経験値の初期表示を設定
    // 旧メソッドは新しいsaveRecordメソッドに置き換えられました
    
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
