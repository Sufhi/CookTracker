import SwiftUI

/// 調理中セッションの状態を表示する共通カード
/// 単一責任: 調理中状態の表示とアクション提供
struct CookingSessionActiveCard: View {
    
    // MARK: - Properties
    @EnvironmentObject private var sessionManager: CookingSessionManager
    let onSessionTap: () -> Void
    
    // MARK: - Body
    var body: some View {
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
                        .fill((sessionManager.currentSession?.isRunning == true) ? .green : .orange)
                        .frame(width: 8, height: 8)
                    
                    Text(sessionManager.currentSessionStatusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sessionManager.currentRecipe?.title ?? "レシピなし")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("経過時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(sessionManager.currentSession?.formattedElapsedTime ?? "00:00")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .monospacedDigit()
                    
                    Text("予想: \(Int(sessionManager.currentRecipe?.estimatedTimeInMinutes ?? 15))分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // アクションボタン
            HStack(spacing: 12) {
                // 調理セッションに戻るボタン
                Button(action: onSessionTap) {
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
                    if let session = sessionManager.currentSession {
                        if session.isRunning {
                            session.pauseCooking()
                        } else {
                            session.startCooking()
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: (sessionManager.currentSession?.isRunning == true) ? "pause.fill" : "play.fill")
                        Text((sessionManager.currentSession?.isRunning == true) ? "一時停止" : "再開")
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
}