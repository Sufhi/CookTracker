// MARK: - Imports
import SwiftUI
import CoreData

/// 調理セッションのメイン画面
/// - カウントアップタイマーによる調理時間記録
/// - 一時停止・再開・終了機能
/// - 補助タイマーアクセス
struct CookingSessionView: View {
    
    // MARK: - Properties
    let recipe: SampleRecipe
    @ObservedObject var cookingSession: CookingSessionTimer
    let onCookingComplete: (CookingSessionRecord) -> Void
    var helperTimer: CookingTimer?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isShowingHelperTimer = false
    @State private var isShowingFinishConfirmation = false
    @State private var isShowingCancelConfirmation = false
    @State private var isShowingCompletionView = false
    @State private var completionRecord: CookingSessionRecord?
    @State private var currentUser: User?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // レシピ情報ヘッダー
                recipeHeaderSection
                
                // メイン調理タイマー
                mainTimerSection
                
                // 調理状態表示
                statusSection
                
                Spacer()
                
                // アクションボタン
                actionButtonsSection
                
                // 補助機能
                helperSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("調理中")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingHelperTimer) {
                if let helperTimer = helperTimer {
                    CookingTimerView(timer: helperTimer)
                } else {
                    CookingTimerView(timer: CookingTimer())
                }
            }
            .alert("調理を完了しますか？", isPresented: $isShowingFinishConfirmation) {
                Button("完了", role: .destructive) {
                    let record = cookingSession.finishCooking()
                    completionRecord = record
                    isShowingCompletionView = true
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("経過時間: \(cookingSession.formattedElapsedTime)\n\n完了後は調理記録として保存されます。")
            }
            .alert("調理をキャンセルしますか？", isPresented: $isShowingCancelConfirmation) {
                Button("キャンセル", role: .destructive) {
                    cookingSession.cancelCooking()
                    dismiss()
                }
                Button("続行", role: .cancel) { }
            } message: {
                Text("経過時間: \(cookingSession.formattedElapsedTime)\n\n調理をキャンセルすると、これまでの記録は保存されません。")
            }
            .sheet(isPresented: $isShowingCompletionView) {
                if let completionRecord = completionRecord {
                    // Core Data Recipe が必要な場合の変換処理
                    let coreDataRecipe = getCoreDataRecipe()
                    CookingCompletionView(
                        recipe: coreDataRecipe,
                        cookingRecord: completionRecord,
                        user: currentUser
                    ) { record in
                        onCookingComplete(completionRecord)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            currentUser = PersistenceController.shared.getOrCreateDefaultUser()
        }
    }
    
    /// SampleRecipe から Core Data Recipe を取得または作成
    private func getCoreDataRecipe() -> Recipe {
        // 既存のレシピを検索
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", recipe.title)
        
        do {
            let recipes = try viewContext.fetch(request)
            if let existingRecipe = recipes.first {
                return existingRecipe
            }
        } catch {
            AppLogger.coreDataError("レシピ検索", error: error)
        }
        
        // 新しいレシピを作成
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = recipe.id
        newRecipe.title = recipe.title
        newRecipe.ingredients = recipe.ingredients
        newRecipe.instructions = recipe.instructions
        newRecipe.category = recipe.category
        newRecipe.difficulty = Int32(recipe.difficulty)
        newRecipe.estimatedTimeInMinutes = Int32(recipe.estimatedTime)
        newRecipe.createdAt = recipe.createdAt
        newRecipe.updatedAt = Date()
        
        PersistenceController.shared.save()
        return newRecipe
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var recipeHeaderSection: some View {
        VStack(spacing: 12) {
            Text(recipe.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack {
                Label("予想 \(recipe.estimatedTime)分", systemImage: "clock")
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text("難易度:")
                    ForEach(0..<5) { index in
                        Image(systemName: index < recipe.difficulty ? "star.fill" : "star")
                            .foregroundColor(index < recipe.difficulty ? .brown : .gray.opacity(0.3))
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brown.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private var mainTimerSection: some View {
        VStack(spacing: 16) {
            Text("経過時間")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(cookingSession.formattedElapsedTime)
                    .font(.system(size: 64, weight: .light, design: .monospaced))
                    .foregroundColor(cookingSession.isRunning ? .brown : .primary)
                    .animation(.easeInOut(duration: 0.3), value: cookingSession.isRunning)
                
                // キャンセルボタン
                if cookingSession.isRunning || cookingSession.isPaused {
                    Button("キャンセル") {
                        isShowingCancelConfirmation = true
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    private var statusSection: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            Text(cookingSession.statusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .animation(.easeInOut(duration: 0.3), value: cookingSession.isRunning)
    }
    
    private var statusColor: Color {
        if cookingSession.isRunning {
            return .green
        } else if cookingSession.isPaused {
            return .orange
        } else {
            return .gray
        }
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        HStack(spacing: 20) {
            // 一時停止/再開ボタン
            if cookingSession.isRunning || cookingSession.isPaused {
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }
            
            // 開始/完了ボタン
            Button(action: {
                if !cookingSession.isRunning && !cookingSession.isPaused {
                    // 調理開始
                    cookingSession.startCooking()
                } else {
                    // 調理完了確認
                    isShowingFinishConfirmation = true
                }
            }) {
                HStack {
                    Image(systemName: cookingButtonIcon)
                    Text(cookingButtonText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(cookingButtonColor.opacity(0.1))
                )
                .foregroundColor(cookingButtonColor)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var cookingButtonIcon: String {
        if !cookingSession.isRunning && !cookingSession.isPaused {
            return "play.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var cookingButtonText: String {
        if !cookingSession.isRunning && !cookingSession.isPaused {
            return "調理開始"
        } else {
            return "調理完了"
        }
    }
    
    private var cookingButtonColor: Color {
        if !cookingSession.isRunning && !cookingSession.isPaused {
            return .green
        } else {
            return .brown
        }
    }
    
    @ViewBuilder
    private var helperSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            Text("調理サポート")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // 補助タイマーボタン
                Button(action: {
                    isShowingHelperTimer = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text("補助タイマー")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(helperTimer != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                    .foregroundColor(helperTimer != nil ? .blue : .gray)
                }
                .buttonStyle(.plain)
                .disabled(helperTimer == nil)
                
                // レシピ確認ボタン（プレースホルダー）
                Button(action: {
                    // 将来実装: レシピ手順の詳細表示
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.title2)
                        Text("手順確認")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .disabled(true) // 将来実装予定
            }
        }
    }
}

// MARK: - Preview
struct CookingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CookingSessionView(
            recipe: SampleRecipe(
                id: UUID(),
                title: "簡単オムライス",
                ingredients: "卵 2個\nご飯 200g\nケチャップ 大さじ2",
                instructions: "1. 卵を溶く\n2. フライパンで焼く",
                category: "食事",
                difficulty: 2,
                estimatedTime: 20,
                createdAt: Date()
            ),
            cookingSession: CookingSessionTimer(),
            onCookingComplete:  { record in
                AppLogger.success("調理セッション完了: \(record.formattedActualTime)")
            }, helperTimer: CookingTimer())
    }
}
