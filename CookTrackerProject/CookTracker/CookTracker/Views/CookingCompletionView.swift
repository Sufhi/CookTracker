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
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var notes = ""
    @State private var isShowingCamera = false
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
                    photoSection
                    
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
            .sheet(isPresented: $isShowingCamera) {
                CameraView { image in
                    photoImages.append(image)
                }
            }
            .onChange(of: selectedPhotos) {
                loadSelectedPhotos()
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
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("完成写真")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 写真表示グリッド
            if !photoImages.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                            
                            Button(action: {
                                photoImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .offset(x: 5, y: -5)
                        }
                    }
                }
            }
            
            // 写真追加ボタン
            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 20 - photoImages.count,
                    matching: .images
                ) {
                    Label("写真を選択", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isShowingCamera = true
                }) {
                    Label("カメラで撮影", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
            
            Text("最大20枚まで保存できます（現在: \(photoImages.count)/20）")
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
    
    /// 選択した写真を読み込み
    private func loadSelectedPhotos() {
        Task {
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        photoImages.append(image)
                    }
                }
            }
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
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

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Level Up Animation View
struct LevelUpAnimationView: View {
    let newLevel: Int
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // レベルアップテキスト
                Text("LEVEL UP!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // 新しいレベル表示
                VStack(spacing: 8) {
                    Text("レベル")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(newLevel)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.orange)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
                
                // キラキラエフェクト
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(sparkleRotation))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            
            // 3秒後に自動で完了
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
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
