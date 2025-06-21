// MARK: - Imports
import SwiftUI
import CoreData

/// 今日の調理提案セクション
/// - おすすめレシピの表示
/// - 調理セッションの開始・継続機能
/// - レシピ詳細情報の表示
struct TodaysSuggestionSection: View {
    let recommendedRecipe: Recipe?
    @EnvironmentObject private var sessionManager: CookingSessionManager
    @Binding var isShowingCookingSession: Bool
    
    /// 調理セッションボタンのテキスト
    private var cookingSessionButtonText: String {
        if let session = sessionManager.currentSession {
            if session.isRunning {
                return "調理中"
            } else if session.isPaused {
                return "調理再開"
            }
        }
        return "調理セッション開始"
    }
    
    var body: some View {
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
                    Text(recommendedRecipe?.title ?? "レシピなし")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    HStack {
                        ForEach(0..<Int(recommendedRecipe?.difficulty ?? 1), id: \.self) { _ in
                            Text("⭐")
                        }
                        Text("難易度")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("予想時間: \(Int(recommendedRecipe?.estimatedTimeInMinutes ?? 15))分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 調理セッション状態表示
                    if sessionManager.isCurrentlyCooking, let session = sessionManager.currentSession {
                        HStack {
                            Circle()
                                .fill(session.isRunning ? .green : .orange)
                                .frame(width: 8, height: 8)
                            Text("調理中: \(session.formattedElapsedTime)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(session.isRunning ? .green : .orange)
                        }
                    }
                }
                
                Spacer()
                
                Button(cookingSessionButtonText) {
                    if sessionManager.isCurrentlyCooking {
                        // 調理中の場合は調理セッション画面を開く
                        isShowingCookingSession = true
                    } else {
                        // 新規調理開始
                        if let recipe = recommendedRecipe {
                            let _ = sessionManager.startCookingSession(for: recipe)
                            isShowingCookingSession = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(sessionManager.isCurrentlyCooking ? .orange : .brown)
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
}

// MARK: - Preview
struct TodaysSuggestionSection_Previews: PreviewProvider {
    static var previews: some View {
        @State var isShowingCookingSession = false
        
        VStack {
            Text("TodaysSuggestionSection Preview")
                .padding()
            
            Text("プレビュー用")
                .padding()
        }
    }
}