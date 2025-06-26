//
//  SimpleCookingCompletionAnimation.swift
//  CookTracker
//
//  Created by Claude on 2025/06/21.
//

import SwiftUI

/// シンプルな調理完了アニメーション（経験値表示なし）
/// - 調理完了の達成感を演出
/// - 経験値変動は保存時に別途表示
struct SimpleCookingCompletionAnimation: View {
    
    // MARK: - Properties
    let cookingTime: TimeInterval
    let onAnimationComplete: () -> Void
    
    @State private var showBackground = false
    @State private var showMainIcon = false
    @State private var showTitle = false
    @State private var showTime = false
    @State private var showContinueButton = false
    @State private var iconScale: CGFloat = 0.1
    @State private var titleOffset: CGFloat = 50
    @State private var showStars = false
    
    private let animationDuration: Double = 0.6
    private let delayBetweenSteps: Double = 0.4
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景グラデーション
            backgroundGradient
            
            VStack(spacing: 40) {
                Spacer()
                
                // メインアイコン（調理完了）
                mainCompletionIcon
                
                // タイトルと時間
                completionContent
                
                Spacer()
                
                // 続行ボタン
                continueButton
                
                Spacer()
            }
            .padding()
            
            // 星のパーティクルエフェクト
            starParticleEffect
        }
        .onAppear {
            print("✨ SimpleCookingCompletionAnimation: onAppear呼び出し")
            print("✨ SimpleCookingCompletionAnimation: アニメーション開始 - 調理時間: \(formattedTime)")
            print("✨ SimpleCookingCompletionAnimation: cookingTime = \(cookingTime)秒")
            startAnimation()
        }
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .brown.opacity(0.8),
                .orange.opacity(0.6),
                .clear
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .opacity(showBackground ? 1 : 0)
        .animation(.easeInOut(duration: animationDuration), value: showBackground)
    }
    
    // MARK: - Main Icon
    @ViewBuilder
    private var mainCompletionIcon: some View {
        ZStack {
            // 外側の円
            Circle()
                .fill(Color.brown.opacity(0.2))
                .frame(width: 160, height: 160)
                .scaleEffect(showMainIcon ? 1.0 : 0.1)
            
            // 内側の円
            Circle()
                .fill(Color.brown.opacity(0.4))
                .frame(width: 120, height: 120)
                .scaleEffect(showMainIcon ? 1.0 : 0.1)
            
            // メインアイコン
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)
                .scaleEffect(iconScale)
        }
        .opacity(showMainIcon ? 1 : 0)
        .scaleEffect(showMainIcon ? 1.0 : 0.1)
        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: showMainIcon)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: iconScale)
    }
    
    // MARK: - Content
    @ViewBuilder
    private var completionContent: some View {
        VStack(spacing: 16) {
            Text("調理完了！")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .offset(y: titleOffset)
                .opacity(showTitle ? 1 : 0)
            
            Text("お疲れ様でした！")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
                .opacity(showTitle ? 1 : 0)
            
            Text("調理時間: \(formattedTime)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .opacity(showTime ? 1 : 0)
                .padding(.top, 8)
        }
        .animation(.easeOut(duration: animationDuration), value: showTitle)
        .animation(.easeOut(duration: animationDuration), value: titleOffset)
        .animation(.easeOut(duration: animationDuration), value: showTime)
    }
    
    private var formattedTime: String {
        let minutes = Int(cookingTime) / 60
        let seconds = Int(cookingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Continue Button
    @ViewBuilder
    private var continueButton: some View {
        Button(action: {
            onAnimationComplete()
        }) {
            Text("調理記録を追加")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                )
        }
        .opacity(showContinueButton ? 1 : 0)
        .scaleEffect(showContinueButton ? 1.0 : 0.8)
        .animation(.easeOut(duration: animationDuration), value: showContinueButton)
    }
    
    // MARK: - Star Particle Effect
    @ViewBuilder
    private var starParticleEffect: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                SimpleStarParticle(
                    delay: Double(index) * 0.15,
                    isActive: showStars
                )
            }
        }
    }
    
    // MARK: - Animation Sequence
    private func startAnimation() {
        print("✨ SimpleCookingCompletionAnimation: startAnimation()呼び出し")
        
        // 1. 背景表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("✨ SimpleCookingCompletionAnimation: 背景表示")
            showBackground = true
        }
        
        // 2. メインアイコン表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps) {
            showMainIcon = true
            showStars = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                iconScale = 1.0
            }
        }
        
        // 3. タイトル表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 1.5) {
            showTitle = true
            titleOffset = 0
        }
        
        // 4. 時間表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 2) {
            showTime = true
        }
        
        // 5. 続行ボタン表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 2.5) {
            showContinueButton = true
        }
    }
}

// MARK: - Simple Star Particle
struct SimpleStarParticle: View {
    let delay: Double
    let isActive: Bool
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.title3)
            .foregroundColor(.orange)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                guard isActive else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let randomX = Double.random(in: -120...120)
                    let randomY = Double.random(in: -150...150)
                    
                    withAnimation(.easeOut(duration: 1.8)) {
                        offset = CGSize(width: randomX, height: randomY)
                        opacity = 0
                    }
                    
                    withAnimation(.easeOut(duration: 0.3)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeOut(duration: 1.4)) {
                            opacity = 0
                            scale = 0.1
                        }
                    }
                }
            }
    }
}

// MARK: - Preview
struct SimpleCookingCompletionAnimation_Previews: PreviewProvider {
    static var previews: some View {
        SimpleCookingCompletionAnimation(
            cookingTime: 1275, // 21:15
            onAnimationComplete: {}
        )
    }
}