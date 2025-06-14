// MARK: - Imports
import SwiftUI
import CoreData

/// アプリのメイン画面（ホーム画面）
/// - 現在のレベル・経験値表示
/// - 最近の料理履歴
/// - 今日の調理提案
/// - クイックアクセスボタン
struct HomeView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.createdAt, ascending: false)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)],
        animation: .default)
    private var recentCookingRecords: FetchedResults<CookingRecord>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var isShowingAddRecipe = false
    @State private var isShowingCookingTimer = false
    
    // MARK: - Computed Properties
    private var currentUser: User? {
        users.first
    }
    
    private var currentLevel: Int {
        Int(currentUser?.level ?? 1)
    }
    
    private var currentExperience: Int {
        Int(currentUser?.experiencePoints ?? 0)
    }
    
    private var experienceToNextLevel: Int {
        // 簡易的なレベリング計算：レベル * 100
        (currentLevel * 100) - currentExperience
    }
    
    private var progressToNextLevel: Double {
        let currentLevelExp = (currentLevel - 1) * 100
        let nextLevelExp = currentLevel * 100
        let currentProgress = currentExperience - currentLevelExp
        let totalNeeded = nextLevelExp - currentLevelExp
        return Double(currentProgress) / Double(totalNeeded)
    }
    
    private var todaysRecommendedRecipe: Recipe? {
        recipes.randomElement()
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ユーザー情報・レベル表示セクション
                    userInfoSection
                    
                    // 今日の調理提案セクション
                    todaysSuggestionSection
                    
                    // クイックアクションボタンセクション
                    quickActionSection
                    
                    // 最近の料理履歴セクション
                    recentHistorySection
                }
                .padding()
            }
            .navigationTitle("CookTracker")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                createUserIfNeeded()
            }
            .sheet(isPresented: $isShowingAddRecipe) {
                AddRecipeView()
            }
            .sheet(isPresented: $isShowingCookingTimer) {
                CookingTimerView()
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var userInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("レベル \(currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("経験値: \(currentExperience) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("次のレベルまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(experienceToNextLevel) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
            }
            
            // 経験値プログレスバー
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("レベル \(currentLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("レベル \(currentLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progressToNextLevel, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
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
    private var todaysSuggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("今日の調理提案")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let recommendedRecipe = todaysRecommendedRecipe {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendedRecipe.title ?? "レシピ")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("難易度: \(String(repeating: "⭐", count: Int(recommendedRecipe.difficulty)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("予想時間: \(recommendedRecipe.estimatedTimeInMinutes)分")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("調理開始") {
                        isShowingCookingTimer = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.brown)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.brown.opacity(0.1))
                )
            } else {
                Text("レシピを追加して調理を始めましょう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
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
    private var quickActionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイックアクション")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: {
                    isShowingAddRecipe = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ追加")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isShowingCookingTimer = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("タイマー")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: RecipeListView()) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ一覧")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
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
            
            if recentCookingRecords.isEmpty {
                Text("まだ料理記録がありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(recentCookingRecords.prefix(3)), id: \.id) { record in
                        recentRecordRow(record: record)
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
    private func recentRecordRow(record: CookingRecord) -> some View {
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
                Text(getRecipeTitle(for: record.recipeId))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(record.cookedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(record.experienceGained) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                Text("\(record.cookingTimeInMinutes)分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Private Methods
    private func createUserIfNeeded() {
        if users.isEmpty {
            let newUser = User(context: viewContext)
            newUser.id = UUID()
            newUser.username = "料理初心者"
            newUser.level = 1
            newUser.experiencePoints = 0
            newUser.isRegistered = false
            newUser.createdAt = Date()
            newUser.updatedAt = Date()
            
            do {
                try viewContext.save()
                print("✅ 新規ユーザー作成完了")
            } catch {
                print("❌ ユーザー作成エラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func getRecipeTitle(for recipeId: UUID?) -> String {
        guard let recipeId = recipeId else { return "不明なレシピ" }
        
        let recipe = recipes.first { $0.id == recipeId }
        return recipe?.title ?? "不明なレシピ"
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}