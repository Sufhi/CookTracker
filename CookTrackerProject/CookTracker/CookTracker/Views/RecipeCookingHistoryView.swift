// MARK: - Imports
import SwiftUI
import CoreData

/// レシピごとの調理履歴一覧画面
/// - 統計サマリーと調理記録の時系列表示
/// - 各記録の詳細情報へのナビゲーション
struct RecipeCookingHistoryView: View {
    
    // MARK: - Properties
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // Core Data取得
    @FetchRequest private var cookingRecords: FetchedResults<CookingRecord>
    
    @State private var selectedRecord: CookingRecord?
    @State private var isShowingCookingSession = false
    @EnvironmentObject private var sessionManager: CookingSessionManager
    @State private var currentUser: User?
    
    // MARK: - Initializer
    init(recipe: Recipe) {
        self.recipe = recipe
        
        // レシピ固有の調理記録を取得
        self._cookingRecords = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)],
            predicate: NSPredicate(format: "recipe == %@", recipe),
            animation: .default
        )
    }
    
    // MARK: - Computed Properties
    private var statistics: CookingStatistics {
        return Array(cookingRecords).cookingStatistics
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 統計サマリーセクション
                    if !cookingRecords.isEmpty {
                        statisticsSection
                    }
                    
                    // 調理記録一覧セクション
                    cookingRecordsSection
                }
                .padding()
            }
            .navigationTitle("調理履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("とじる") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("調理開始") {
                        isShowingCookingSession = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.brown)
                }
            }
            .sheet(item: $selectedRecord) { record in
                CookingRecordDetailView(cookingRecord: record)
            }
            .sheet(isPresented: $isShowingCookingSession) {
                if let currentRecipe = sessionManager.currentRecipe,
                   let currentSession = sessionManager.currentSession {
                    CookingSessionView(
                        recipe: RecipeConverter.toSampleRecipe(currentRecipe),
                        cookingSession: currentSession,
                        onCookingComplete: { sampleRecord in
                            print("✅ 新しい調理記録が追加されました")
                            sessionManager.finishCookingSession()
                        },
                        helperTimer: sessionManager.sharedHelperTimer
                    )
                }
            }
            .onAppear {
                currentUser = PersistenceController.shared.getOrCreateDefaultUser()
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.brown)
                Text("\(recipe.title ?? "レシピ")の統計")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // 統計データ
            VStack(spacing: 12) {
                HStack {
                    statisticItem(
                        title: "調理回数",
                        value: "\(statistics.totalCount)回",
                        icon: "fork.knife.circle"
                    )
                    
                    Spacer()
                    
                    statisticItem(
                        title: "平均時間",
                        value: statistics.formattedAverageTime,
                        icon: "clock"
                    )
                }
                
                HStack {
                    statisticItem(
                        title: "最短時間",
                        value: statistics.formattedShortestTime,
                        icon: "speedometer",
                        subtitle: statistics.shortestRecord?.formattedShortDate
                    )
                    
                    Spacer()
                    
                    statisticItem(
                        title: "最長時間", 
                        value: statistics.formattedLongestTime,
                        icon: "timer",
                        subtitle: statistics.longestRecord?.formattedShortDate
                    )
                }
                
                HStack {
                    statisticItem(
                        title: "写真記録",
                        value: "\(statistics.photoRecordsCount)/\(statistics.totalCount)回",
                        icon: "camera.fill",
                        subtitle: String(format: "%.0f%%", statistics.photoRecordsRatio * 100)
                    )
                    
                    Spacer()
                    
                    statisticItem(
                        title: "メモ記録",
                        value: "\(statistics.memoRecordsCount)/\(statistics.totalCount)回",
                        icon: "note.text",
                        subtitle: String(format: "%.0f%%", statistics.memoRecordsRatio * 100)
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
    private func statisticItem(title: String, value: String, icon: String, subtitle: String? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brown)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var cookingRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションヘッダー
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.brown)
                Text("調理記録")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !cookingRecords.isEmpty {
                    Text("\(cookingRecords.count)件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 調理記録一覧
            if cookingRecords.isEmpty {
                // 空状態
                emptyStateView
            } else {
                // 記録一覧
                LazyVStack(spacing: 12) {
                    ForEach(Array(cookingRecords), id: \.id) { record in
                        CookingRecordRowView(record: record) {
                            selectedRecord = record
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 50))
                .foregroundColor(.brown.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("まだ作ったことがないよ")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("\(recipe.title ?? "このレシピ")を作って\n最初の記録を残してみよう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("作ってみる") {
                let _ = sessionManager.startCookingSession(for: recipe)
                isShowingCookingSession = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.brown)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGroupedBackground))
        )
    }
}

// MARK: - Cooking Record Row View

struct CookingRecordRowView: View {
    let record: CookingRecord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // メイン情報
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // 調理日時
                        Text(record.formattedDetailedDate)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // 調理時間比較
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text(record.formattedCookingTime)
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            
                            // 予想時間との比較
                            if let recipe = record.recipe {
                                HStack(spacing: 2) {
                                    Text("(予想\(Int(recipe.estimatedTimeInMinutes))分")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(record.timeDifferenceText + ")")
                                        .font(.caption)
                                        .foregroundColor(colorForTimeComparison(record.timeComparisonStatus))
                                }
                            }
                        }
                        
                        // 経験値
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.brown)
                            Text("+\(record.experienceGained) XP")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.brown)
                        }
                    }
                    
                    Spacer()
                    
                    // 時間比較アイコン
                    VStack(spacing: 8) {
                        Image(systemName: record.timeComparisonStatus.icon)
                            .font(.title3)
                            .foregroundColor(colorForTimeComparison(record.timeComparisonStatus))
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 写真・メモ情報
                HStack {
                    // 写真情報
                    HStack(spacing: 4) {
                        Image(systemName: record.hasPhotos ? "camera.fill" : "camera")
                            .font(.caption)
                            .foregroundColor(record.hasPhotos ? .blue : .secondary)
                        Text(record.hasPhotos ? "\(record.photoCount)枚" : "写真なし")
                            .font(.caption)
                            .foregroundColor(record.hasPhotos ? .blue : .secondary)
                    }
                    
                    Spacer()
                    
                    // メモ情報
                    HStack(spacing: 4) {
                        Image(systemName: record.hasNotes ? "note.text" : "note")
                            .font(.caption)
                            .foregroundColor(record.hasNotes ? .green : .secondary)
                        Text(record.hasNotes ? "メモあり" : "メモなし")
                            .font(.caption)
                            .foregroundColor(record.hasNotes ? .green : .secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func colorForTimeComparison(_ status: TimeComparisonStatus) -> Color {
        switch status {
        case .faster: return .green
        case .exact: return .yellow
        case .slower: return .orange
        case .unknown: return .gray
        }
    }
}

// MARK: - Preview
struct RecipeCookingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let recipe = Recipe(context: context)
        recipe.title = "テストレシピ"
        recipe.estimatedTimeInMinutes = 20
        
        return RecipeCookingHistoryView(recipe: recipe)
            .environment(\.managedObjectContext, context)
    }
}