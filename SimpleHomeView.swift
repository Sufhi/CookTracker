// MARK: - Imports
import SwiftUI

/// 基本的なホーム画面（Core Dataなし版）
/// - レベル・経験値の静的表示
/// - クイックアクションボタン
struct SimpleHomeView: View {
    
    // MARK: - Properties
    @State private var isShowingAddRecipe = false
    @State private var isShowingTimer = false
    @State private var isShowingCookingSession = false
    @StateObject private var cookingSession = CookingSessionTimer()
    
    // 静的なデータ（後でCore Dataに置き換え）
    private let currentLevel = 3
    private let currentExperience = 150
    private let experienceToNextLevel = 150
    private let progressToNextLevel = 0.5
    
    // おすすめレシピのサンプルデータ
    private let suggestedRecipe = SampleRecipe(
        id: UUID(),
        title: "簡単オムライス",
        ingredients: "卵 2個\nご飯 200g\nケチャップ 大さじ2\n玉ねぎ 1/4個\nベーコン 2枚",
        instructions: "1. 玉ねぎとベーコンを炒める\n2. ご飯を加えてケチャップで味付け\n3. 卵でふわふわに包む",
        category: "食事",
        difficulty: 2,
        estimatedTime: 20,
        createdAt: Date()
    )
    
    // MARK: - Computed Properties
    
    /// 調理セッションボタンのテキスト
    private var cookingSessionButtonText: String {
        if cookingSession.isRunning {
            return "調理中"
        } else if cookingSession.isPaused {
            return "調理再開"
        } else {
            return "調理セッション開始"
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ユーザー情報・レベル表示セクション
                userInfoSection
                
                // 調理セッション中カード（調理中のみ表示）
                if cookingSession.isRunning || cookingSession.isPaused {
                    cookingSessionActiveCard
                }
                
                // 今日の調理提案セクション（調理中でない場合のみ表示）
                if !cookingSession.isRunning && !cookingSession.isPaused {
                    todaysSuggestionSection
                }
                
                // クイックアクションボタンセクション
                quickActionSection
                
                // 最近の料理履歴セクション
                recentHistorySection
            }
            .padding()
        }
        .navigationTitle("CookTracker")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isShowingAddRecipe) {
            AddRecipeSheetView()
        }
        .sheet(isPresented: $isShowingTimer) {
            CookingTimerView()
        }
        .sheet(isPresented: $isShowingCookingSession) {
            CookingSessionView(
                recipe: suggestedRecipe,
                cookingSession: cookingSession
            ) { record in
                // 将来: Core Dataに保存
                print("✅ おすすめレシピ調理完了: \(record.formattedActualTime)")
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
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestedRecipe.title)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    HStack {
                        ForEach(0..<suggestedRecipe.difficulty) { _ in
                            Text("⭐")
                        }
                        Text("難易度")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("予想時間: \(suggestedRecipe.estimatedTime)分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 調理セッション状態表示
                    if cookingSession.isRunning || cookingSession.isPaused {
                        HStack {
                            Circle()
                                .fill(cookingSession.isRunning ? .green : .orange)
                                .frame(width: 8, height: 8)
                            Text("調理中: \(cookingSession.formattedElapsedTime)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(cookingSession.isRunning ? .green : .orange)
                        }
                    }
                }
                
                Spacer()
                
                Button(cookingSessionButtonText) {
                    if cookingSession.isRunning || cookingSession.isPaused {
                        // 調理中の場合は調理セッション画面を開く
                        isShowingCookingSession = true
                    } else {
                        // 新規調理開始
                        isShowingCookingSession = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(cookingSession.isRunning || cookingSession.isPaused ? .orange : .brown)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brown.opacity(0.1))
            )
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
                    isShowingTimer = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("補助タイマー")
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
                    // レシピ一覧は後で実装
                }) {
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
            
            // サンプルデータ
            VStack(spacing: 8) {
                recentRecordRow(title: "オムライス", date: "06/13", exp: 15, time: 22)
                recentRecordRow(title: "味噌汁", date: "06/12", exp: 10, time: 8)
                recentRecordRow(title: "焼きそば", date: "06/11", exp: 12, time: 15)
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
    
    @ViewBuilder
    private var cookingSessionActiveCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("調理中")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                // 状態インジケーター
                HStack(spacing: 6) {
                    Circle()
                        .fill(cookingSession.isRunning ? .green : .orange)
                        .frame(width: 8, height: 8)
                    
                    Text(cookingSession.statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestedRecipe.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("経過時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(cookingSession.formattedElapsedTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .monospacedDigit()
                    
                    Text("予想: \(suggestedRecipe.estimatedTime)分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // アクションボタン
            HStack(spacing: 12) {
                // 調理セッションに戻るボタン
                Button(action: {
                    isShowingCookingSession = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("セッションに戻る")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                    )
                }
                .buttonStyle(.plain)
                
                // 一時停止/再開ボタン
                Button(action: {
                    if cookingSession.isRunning {
                        cookingSession.pauseCooking()
                    } else {
                        cookingSession.startCooking()
                    }
                }) {
                    HStack {
                        Image(systemName: cookingSession.isRunning ? "pause.fill" : "play.fill")
                        Text(cookingSession.isRunning ? "一時停止" : "再開")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Sheet Views
struct AddRecipeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Preview
struct SimpleHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleHomeView()
        }
    }
}