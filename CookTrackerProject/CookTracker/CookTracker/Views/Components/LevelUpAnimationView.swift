// MARK: - Imports
import SwiftUI

/// レベルアップ時のアニメーション表示ビュー
/// - リッチなレベルアップ演出を提供
/// - 自動完了機能付き
struct LevelUpAnimationView: View {
    let newLevel: Int
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // レベルアップテキスト
                Text("LEVEL UP!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // 新しいレベル表示
                VStack(spacing: 8) {
                    Text("レベル")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(newLevel)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.orange)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
                
                // キラキラエフェクト
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(sparkleRotation))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            
            // 3秒後に自動で完了
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Preview
struct LevelUpAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LevelUpAnimationView(newLevel: 5) {
            print("Animation completed")
        }
    }
}