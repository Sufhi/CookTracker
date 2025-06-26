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
    @State private var isShowingCompletionAnimation = false
    @State private var completionRecord: CookingSessionRecord?
    @State private var currentUser: User?
    @State private var cookingCompletionTime: TimeInterval?
    
    // デバッグ用状態追跡
    @State private var animationTriggerCount = 0
    
    // 代替表示フラグ（デバッグ用）
    @State private var useDirectCompletion = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カスタムヘッダー
                HStack {
                    Button("閉じる") {
                        dismiss()
                    }
                    Spacer()
                    Text("調理中")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    // バランス用の透明ボタン
                    Button("") { }
                        .opacity(0)
                        .disabled(true)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
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
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingHelperTimer) {
                if let helperTimer = helperTimer {
                    CookingTimerView(timer: helperTimer)
                } else {
                    CookingTimerView(timer: CookingTimer())
                }
            }
            .alert("調理を完了しますか？", isPresented: $isShowingFinishConfirmation) {
                Button("完了", role: .destructive) {
                    handleCookingCompletion()
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
            .fullScreenCover(isPresented: $isShowingCompletionAnimation) {
                Group {
                    if let cookingTime = cookingCompletionTime {
                        SimpleCookingCompletionAnimation(
                            cookingTime: cookingTime
                        ) {
                            print("🔥 CookingSessionView: アニメーション完了コールバック")
                            DispatchQueue.main.async {
                                isShowingCompletionAnimation = false
                                // わずかな遅延を入れて次の画面表示を確実にする
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isShowingCompletionView = true
                                }
                            }
                        }
                        .onAppear {
                            print("🔥 CookingSessionView: SimpleCookingCompletionAnimation.onAppear呼び出し")
                        }
                    } else {
                        // fallback: 直接記録画面へ
                        VStack {
                            Text("アニメーションロード中...")
                                .font(.headline)
                                .padding()
                            
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .onAppear {
                            print("🔥 CookingSessionView: フォールバック表示、0.5秒後に記録画面へ")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isShowingCompletionAnimation = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isShowingCompletionView = true
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    print("🔥 CookingSessionView: fullScreenCover ビルダー呼び出し")
                    print("🔥 CookingSessionView: cookingCompletionTime = \(String(describing: cookingCompletionTime))")
                    print("🔥 CookingSessionView: completionRecord = \(completionRecord != nil)")
                }
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
                        // CookingSessionRecordを渡す（型の一致）
                        onCookingComplete(completionRecord)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🔥 CookingSessionView: onAppear - ユーザー初期化")
            currentUser = PersistenceController.shared.getOrCreateDefaultUser()
            print("🔥 CookingSessionView: ユーザー初期化完了: \(currentUser != nil)")
        }
    }
    
    /// 調理完了処理（経験値は保存時に処理）
    private func handleCookingCompletion() {
        animationTriggerCount += 1
        print("🔥 CookingSessionView: 調理完了処理開始 (トリガー回数: \(animationTriggerCount))")
        AppLogger.debug("CookingSessionView: 調理完了処理開始")
        
        // 他のモーダルが表示されていないことを確認
        guard !isShowingCompletionAnimation && !isShowingCompletionView else {
            print("⚠️ CookingSessionView: 既にモーダルが表示中 - animation: \(isShowingCompletionAnimation), view: \(isShowingCompletionView)")
            return
        }
        
        let record = cookingSession.finishCooking()
        completionRecord = record
        cookingCompletionTime = record.actualCookingTime
        
        print("🔥 CookingSessionView: 調理時間 = \(record.actualCookingTime)秒")
        print("🔥 CookingSessionView: completionRecord設定完了: \(completionRecord != nil)")
        print("🔥 CookingSessionView: cookingCompletionTime設定完了: \(cookingCompletionTime != nil), 値: \(String(describing: cookingCompletionTime))")
        
        AppLogger.debug("CookingSessionView: 調理時間 = \(record.actualCookingTime)秒, レコード設定: \(completionRecord != nil)")
        
        // 状態の変更を確実に行う
        print("🔥 CookingSessionView: アニメーション表示開始")
        
        // わずかな遅延を入れて確実にプロパティを設定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            print("🔥 CookingSessionView: メインスレッドでisShowingCompletionAnimationをtrueに設定")
            
            // @Stateプロパティの変更前にログ出力
            print("🔥 CookingSessionView: 設定前 - isShowingCompletionAnimation = \(isShowingCompletionAnimation)")
            
            isShowingCompletionAnimation = true
            
            print("🔥 CookingSessionView: 設定後 - isShowingCompletionAnimation = \(isShowingCompletionAnimation)")
            
            // さらに遅延してもう一度確認
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("🔥 CookingSessionView: 0.1秒後チェック - isShowingCompletionAnimation = \(isShowingCompletionAnimation)")
                if !isShowingCompletionAnimation {
                    print("❌ CookingSessionView: アニメーション状態が予期せずfalseに戻っている！")
                    // 代替ルート: 直接記録画面を表示
                    print("🔥 CookingSessionView: 代替ルートで記録画面を表示")
                    useDirectCompletion = true
                    isShowingCompletionView = true
                }
            }
            
            // 最終手段: さらに長い遅延でチェック
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !isShowingCompletionAnimation && !isShowingCompletionView {
                    print("🚨 CookingSessionView: 最終手段 - 直接記録画面を表示")
                    useDirectCompletion = true
                    isShowingCompletionView = true
                }
            }
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
