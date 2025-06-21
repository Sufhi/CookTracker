// MARK: - Imports
import SwiftUI
import CoreData

/// Core Dataを使用するホーム画面
/// - ユーザーのレベル・経験値をリアルタイム表示
/// - レシピ提案・クイックアクション
struct SimpleHomeView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isShowingAddRecipe = false
    @State private var isShowingTimer = false
    @State private var isShowingCookingSession = false
    @State private var isShowingSettings = false
    @EnvironmentObject private var sessionManager: CookingSessionManager
    
    // Core Data取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
        predicate: NSPredicate(format: "category == %@", "食事"),
        animation: .default
    ) private var suggestedRecipes: FetchedResults<Recipe>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)],
        animation: .default
    ) private var recentCookingRecords: FetchedResults<CookingRecord>
    
    // MARK: - Computed Properties
    
    
    /// 推奨レシピ（ランダム選択）
    private var recommendedRecipe: Recipe? {
        guard !suggestedRecipes.isEmpty else { return nil }
        return suggestedRecipes.randomElement()
    }
    
    
    /// 調理統計データ
    private var cookingStatsData: CookingStatsData {
        let records = Array(recentCookingRecords)
        return CookingStatsData(records: records)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 固定表示エリア
            VStack(spacing: 8) {
                // 調理セッション中カード（固定表示）
                if sessionManager.isCurrentlyCooking {
                    CookingSessionActiveCard(onSessionTap: {
                        isShowingCookingSession = true
                    })
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: sessionManager.currentSession?.isRunning)
                }
                
                // 補助タイマーカード（動作中・一時停止中に表示）
                if sessionManager.sharedHelperTimer.isRunning || (sessionManager.sharedHelperTimer.timeRemaining > 0 && !sessionManager.sharedHelperTimer.isRunning && !sessionManager.sharedHelperTimer.isFinished) {
                    HelperTimerCompactCard(isShowingTimer: $isShowingTimer)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: sessionManager.sharedHelperTimer.isRunning)
                }
            }
            .background(Color(.systemGroupedBackground))
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            .padding(.bottom, (sessionManager.isCurrentlyCooking || sessionManager.sharedHelperTimer.isRunning || (sessionManager.sharedHelperTimer.timeRemaining > 0 && !sessionManager.sharedHelperTimer.isFinished)) ? 4 : 0)
            
            // スクロール可能なメインコンテンツ
            ScrollView {
                VStack(spacing: 20) {
                    // 調理統計セクション
                    cookingStatsSection
                    
                    // ユーザー情報・レベル表示セクション
                    UserStatusCard.forHome()
                    
                    // 今日の調理提案セクション（調理中でない場合のみ表示）
                    if !sessionManager.isCurrentlyCooking {
                        TodaysSuggestionSection(
                            recommendedRecipe: recommendedRecipe,
                            isShowingCookingSession: $isShowingCookingSession
                        )
                    }
                    
                    // クイックアクションボタンセクション
                    QuickActionSection(
                        isShowingAddRecipe: $isShowingAddRecipe,
                        isShowingTimer: $isShowingTimer
                    )
                    
                    // 最近の料理履歴セクション
                    recentHistorySection
                }
                .padding()
            }
        }
        .navigationTitle("CookTracker")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isShowingAddRecipe) {
            RecipeFormView()
        }
        .sheet(isPresented: $isShowingTimer) {
            CookingTimerView(timer: sessionManager.sharedHelperTimer)
        }
        .sheet(isPresented: $isShowingCookingSession) {
            if let currentRecipe = sessionManager.currentRecipe,
               let currentSession = sessionManager.currentSession {
                CookingSessionView(
                    recipe: RecipeConverter.toSampleRecipe(currentRecipe),
                    cookingSession: currentSession,
                    onCookingComplete: { sampleRecord in
                        print("✅ 調理完了: \(sampleRecord.formattedActualTime)")
                        
                        // 調理記録を Core Data に保存して経験値を付与
                        let currentUser = PersistenceController.shared.getOrCreateDefaultUser()
                        let (_, didLevelUp, experience) = ExperienceService.shared.createCookingRecordWithExperience(
                            context: viewContext,
                            recipe: currentRecipe,
                            cookingTime: sampleRecord.actualMinutes,
                            user: currentUser
                        )
                        
                        // Core Data保存
                        PersistenceController.shared.save()
                        
                        print("🎉 経験値獲得: +\(experience) XP, レベルアップ: \(didLevelUp)")
                        
                        sessionManager.finishCookingSession()
                    },
                    helperTimer: sessionManager.sharedHelperTimer
                )
            }
        }
    }
    
    // MARK: - View Components
    
    
    
    @ViewBuilder
    private var recentHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.brown)
                Text("最近の料理履歴")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Core Dataからの履歴データ
            VStack(spacing: 8) {
                if recentCookingRecords.isEmpty {
                    Text("まだ調理記録がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(recentCookingRecords.prefix(3)), id: \.id) { record in
                        recentRecordRow(
                            title: record.recipe?.title ?? "不明なレシピ",
                            date: formatDate(record.cookedAt ?? Date()),
                            exp: Int(record.experienceGained),
                            time: Int(record.cookingTimeInMinutes)
                        )
                    }
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
    private func recentRecordRow(title: String, date: String, exp: Int, time: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brown.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(.brown)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(exp) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                Text("\(time)分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    
    
    // MARK: - Methods
    
    /// 日付フォーマット
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Cooking Stats Section
    @ViewBuilder
    private var cookingStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションヘッダー
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.brown)
                    .font(.title3)
                
                Text("調理の継続状況")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                Spacer()
            }
            
            // 継続メッセージ
            if cookingStatsData.totalDays > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text(cookingStatsData.continuityMessage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if cookingStatsData.currentStreak > 0 {
                        Text("現在\(cookingStatsData.currentStreak)日連続で調理中です！")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.brown.opacity(0.1))
                )
            }
            
            // 統計グリッド
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // 総調理日数
                StatCard(
                    icon: "calendar.circle.fill",
                    iconColor: Color.blue,
                    title: "総調理日数",
                    value: "\(cookingStatsData.totalDays)日",
                    subtitle: "累計\(cookingStatsData.totalRecords)回調理"
                )
                
                // 現在の連続日数
                StatCard(
                    icon: "flame.circle.fill",
                    iconColor: cookingStatsData.currentStreak > 0 ? Color.orange : Color.gray,
                    title: "連続調理",
                    value: "\(cookingStatsData.currentStreak)日",
                    subtitle: "最高\(cookingStatsData.longestStreak)日"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}


// MARK: - Sheet Views


// MARK: - Preview
struct SimpleHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleHomeView()
        }
    }
}
