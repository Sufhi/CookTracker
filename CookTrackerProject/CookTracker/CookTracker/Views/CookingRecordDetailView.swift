// MARK: - Imports
import SwiftUI
import CoreData

/// 調理記録詳細画面
/// - 特定の調理記録の詳細情報を表示
/// - 写真ギャラリー、メモ、調理コンテキストを含む
struct CookingRecordDetailView: View {
    
    // MARK: - Properties
    let cookingRecord: CookingRecord
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedPhotoIndex: Int = 0
    @State private var isShowingPhotoGallery = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー情報
                    headerSection
                    
                    // 調理時間情報
                    cookingTimeSection
                    
                    // 写真ギャラリー
                    photoSection
                    
                    // 改善メモ
                    notesSection
                    
                    // 調理コンテキスト
                    contextSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("調理記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingPhotoGallery) {
                PhotoGalleryView(
                    photoPaths: getPhotoPaths(),
                    selectedIndex: $selectedPhotoIndex
                )
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 完了アイコン
            ZStack {
                Circle()
                    .fill(Color.brown.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.brown)
            }
            
            VStack(spacing: 8) {
                Text("調理完了記録")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(cookingRecord.recipe?.title ?? "レシピ")
                    .font(.headline)
                    .foregroundColor(.brown)
                
                Text(cookingRecord.formattedDetailedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var cookingTimeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.brown)
                Text("調理時間")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    timeInfoItem(
                        title: "実際の時間",
                        value: cookingRecord.formattedCookingTime,
                        icon: "stopwatch",
                        color: .primary
                    )
                    
                    Spacer()
                    
                    if let recipe = cookingRecord.recipe {
                        timeInfoItem(
                            title: "予想時間",
                            value: "\(Int(recipe.estimatedTimeInMinutes))分",
                            icon: "clock",
                            color: .brown
                        )
                    }
                }
                
                // 時間比較結果
                HStack {
                    Image(systemName: cookingRecord.timeComparisonStatus.icon)
                        .font(.title3)
                        .foregroundColor(colorForTimeComparison(cookingRecord.timeComparisonStatus))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(timeComparisonText(cookingRecord.timeComparisonStatus))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(colorForTimeComparison(cookingRecord.timeComparisonStatus))
                        
                        Text(cookingRecord.timeDifferenceText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 経験値情報
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.brown)
                        Text("+\(cookingRecord.experienceGained) XP")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGroupedBackground))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private func timeInfoItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.brown)
                Text("完成写真")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if cookingRecord.hasPhotos {
                    Text("\(cookingRecord.photoCount)枚")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if cookingRecord.hasPhotos {
                // 写真グリッド表示
                let photoPaths = getPhotoPaths()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(Array(photoPaths.enumerated()), id: \.offset) { index, photoPath in
                        Button(action: {
                            selectedPhotoIndex = index
                            isShowingPhotoGallery = true
                        }) {
                            PhotoThumbnailView(photoPath: photoPath)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                // 写真なし状態
                VStack(spacing: 12) {
                    Image(systemName: "camera")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("写真がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGroupedBackground))
                )
            }
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
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.brown)
                Text("改善メモ")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if cookingRecord.hasNotes {
                Text(cookingRecord.notes ?? "")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGroupedBackground))
                    )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "note")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("メモがありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGroupedBackground))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.brown)
                Text("調理コンテキスト")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // レシピ難易度（調理時点）
                if let recipe = cookingRecord.recipe {
                    contextItem(
                        icon: "star.fill",
                        title: "レシピ難易度",
                        value: difficultyText(Int(recipe.difficulty)),
                        color: .brown
                    )
                }
                
                // 調理順序（このレシピの何回目か）
                contextItem(
                    icon: "number.circle.fill",
                    title: "調理順序",
                    value: "このレシピの\(getCookingSequence())回目",
                    color: .blue
                )
                
                // 調理時間帯
                if let cookedAt = cookingRecord.cookedAt {
                    let timeOfDay = getTimeOfDay(date: cookedAt)
                    contextItem(
                        icon: timeOfDay.icon,
                        title: "調理時間帯",
                        value: timeOfDay.description,
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private func contextItem(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Methods
    
    private func getPhotoPaths() -> [String] {
        guard let paths = cookingRecord.photoPaths as? [String] else { return [] }
        return paths
    }
    
    private func colorForTimeComparison(_ status: TimeComparisonStatus) -> Color {
        switch status {
        case .faster: return .green
        case .exact: return .yellow
        case .slower: return .orange
        case .unknown: return .gray
        }
    }
    
    private func timeComparisonText(_ status: TimeComparisonStatus) -> String {
        switch status {
        case .faster: return "予想より早く完了"
        case .exact: return "予想通りに完了"
        case .slower: return "予想より時間がかかった"
        case .unknown: return "比較データなし"
        }
    }
    
    private func difficultyText(_ difficulty: Int) -> String {
        let stars = String(repeating: "⭐", count: difficulty)
        let descriptions = ["", "簡単", "普通", "やや難しい", "難しい", "とても難しい"]
        let description = difficulty <= descriptions.count - 1 ? descriptions[difficulty] : "不明"
        return "\(stars) \(description)"
    }
    
    private func getCookingSequence() -> Int {
        guard let recipe = cookingRecord.recipe,
              let recipeId = recipe.id else {
            return 1
        }
        
        let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %@ AND cookedAt <= %@", 
                                       recipeId as CVarArg, 
                                       cookingRecord.cookedAt as CVarArg? ?? Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: true)]
        
        do {
            let records = try viewContext.fetch(request)
            return records.count
        } catch {
            AppLogger.coreDataError("調理回数取得", error: error)
            return 1
        }
    }
    
    private func getTimeOfDay(date: Date) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 5..<12:
            return TimeOfDay(description: "朝", icon: "sunrise.fill")
        case 12..<17:
            return TimeOfDay(description: "昼", icon: "sun.max.fill")
        case 17..<21:
            return TimeOfDay(description: "夕方", icon: "sunset.fill")
        default:
            return TimeOfDay(description: "夜", icon: "moon.stars.fill")
        }
    }
}

// MARK: - Supporting Views

struct PhotoThumbnailView: View {
    let photoPath: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brown.opacity(0.1))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundColor(.brown.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.brown.opacity(0.3), lineWidth: 1)
            )
    }
}

struct PhotoGalleryView: View {
    let photoPaths: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // 写真表示エリア
                TabView(selection: $selectedIndex) {
                    ForEach(Array(photoPaths.enumerated()), id: \.offset) { index, photoPath in
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brown.opacity(0.1))
                                .frame(maxWidth: .infinity, maxHeight: 400)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.brown.opacity(0.6))
                                        
                                        Text("写真 \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                
                Spacer()
                
                // ページインジケーター
                if photoPaths.count > 1 {
                    HStack {
                        Text("\(selectedIndex + 1) / \(photoPaths.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("完成写真")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct TimeOfDay {
    let description: String
    let icon: String
}

// MARK: - Preview
struct CookingRecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let record = CookingRecord(context: context)
        record.cookingTimeInMinutes = 25
        record.experienceGained = 15
        record.cookedAt = Date()
        record.notes = "塩加減が丁度良かった。次回はもう少し強火で炒めてみよう。"
        
        return CookingRecordDetailView(cookingRecord: record)
    }
}