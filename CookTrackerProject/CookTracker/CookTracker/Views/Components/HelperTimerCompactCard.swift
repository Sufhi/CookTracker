// MARK: - Imports
import SwiftUI

/// 補助タイマーのコンパクト表示カード
/// - 動作中・一時停止中の補助タイマーを簡易表示
/// - 一時停止/再開、タイマー画面への遷移機能
/// - ホーム画面での固定表示用コンポーネント
struct HelperTimerCompactCard: View {
    @EnvironmentObject private var sessionManager: CookingSessionManager
    @Binding var isShowingTimer: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // タイマーアイコンと状態
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                Text("補助タイマー")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 時間表示
            Text(sessionManager.sharedHelperTimer.formattedTime)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.blue)
            
            // 状態インジケーター
            Circle()
                .fill(sessionManager.sharedHelperTimer.isRunning ? .green : .orange)
                .frame(width: 8, height: 8)
            
            // 操作ボタン
            HStack(spacing: 8) {
                // 一時停止/再開ボタン
                Button(action: {
                    if sessionManager.sharedHelperTimer.isRunning {
                        sessionManager.sharedHelperTimer.pauseTimer()
                    } else if sessionManager.sharedHelperTimer.timeRemaining > 0 {
                        sessionManager.sharedHelperTimer.resumeTimer()
                    }
                }) {
                    Image(systemName: sessionManager.sharedHelperTimer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .disabled(sessionManager.sharedHelperTimer.timeRemaining == 0)
                
                // タイマー画面を開くボタン
                Button(action: {
                    isShowingTimer = true
                }) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct HelperTimerCompactCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("HelperTimerCompactCard Preview")
                .padding()
            
            Text("プレビュー用")
                .padding()
        }
    }
}