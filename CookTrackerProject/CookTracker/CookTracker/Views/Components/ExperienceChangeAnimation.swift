//
//  ExperienceChangeAnimation.swift
//  CookTracker
//
//  Created by Claude on 2025/06/21.
//

import SwiftUI

/// 経験値変動専用アニメーション（再利用可能モジュール）
/// - 様々な場面で使用可能（調理完了、レシピ登録、達成など）
/// - レベルアップ判定とアニメーション対応
struct ExperienceChangeAnimation: View {
    
    // MARK: - Properties
    let experienceGained: Int
    let didLevelUp: Bool
    let oldLevel: Int
    let newLevel: Int
    let context: ExperienceContext
    let onAnimationComplete: () -> Void
    
    @State private var showBackground = false
    @State private var showMainIcon = false
    @State private var showExperience = false
    @State private var showLevelUp = false
    @State private var showContinueButton = false
    @State private var iconScale: CGFloat = 0.1
    @State private var experienceProgress: CGFloat = 0
    @State private var levelUpBounce: CGFloat = 1.0
    @State private var showStars = false
    @State private var rotationAngle: Double = 0
    
    private let animationDuration: Double = 0.6
    private let delayBetweenSteps: Double = 0.3
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景グラデーション
            backgroundGradient
            
            VStack(spacing: 40) {
                Spacer()
                
                // メインアイコン
                mainIcon
                
                // タイトル
                titleSection
                
                // 経験値セクション
                experienceSection
                
                // レベルアップセクション
                if didLevelUp {
                    levelUpSection
                }
                
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
            startAnimation()
        }
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: didLevelUp ? levelUpColors : experienceColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .opacity(showBackground ? 1 : 0)
        .animation(.easeInOut(duration: animationDuration), value: showBackground)
    }
    
    private var levelUpColors: [Color] {
        [.purple, .blue, .indigo]
    }
    
    private var experienceColors: [Color] {
        [.brown, .orange, .yellow.opacity(0.8)]
    }
    
    // MARK: - Main Icon
    @ViewBuilder
    private var mainIcon: some View {
        ZStack {
            // 外側の円
            Circle()
                .fill((didLevelUp ? Color.purple : Color.brown).opacity(0.2))
                .frame(width: 160, height: 160)
                .scaleEffect(showMainIcon ? 1.0 : 0.1)
            
            // 内側の円
            Circle()
                .fill((didLevelUp ? Color.purple : Color.brown).opacity(0.4))
                .frame(width: 120, height: 120)
                .scaleEffect(showMainIcon ? 1.0 : 0.1)
            
            // メインアイコン
            Image(systemName: didLevelUp ? "star.fill" : context.iconName)
                .font(.system(size: 60))
                .foregroundColor(didLevelUp ? .yellow : .brown)
                .scaleEffect(iconScale)
                .rotationEffect(.degrees(rotationAngle))
        }
        .opacity(showMainIcon ? 1 : 0)
        .scaleEffect(showMainIcon ? 1.0 : 0.1)
        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: showMainIcon)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: iconScale)
    }
    
    // MARK: - Title
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(didLevelUp ? "レベルアップ！" : context.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(showMainIcon ? 1 : 0)
            
            Text(context.subtitle)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .opacity(showMainIcon ? 1 : 0)
        }
        .animation(.easeOut(duration: animationDuration), value: showMainIcon)
    }
    
    // MARK: - Experience Section
    @ViewBuilder
    private var experienceSection: some View {
        VStack(spacing: 16) {
            Text("+\(experienceGained) XP")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .scaleEffect(showExperience ? 1.0 : 0.1)
                .opacity(showExperience ? 1 : 0)
            
            // 経験値バー（アニメーション）
            experienceBar
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0), value: showExperience)
    }
    
    @ViewBuilder
    private var experienceBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("経験値")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("+\(experienceGained)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
            }
            
            // プログレスバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // 進捗
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.yellow, .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * experienceProgress, height: 8)
                }
            }
            .frame(height: 8)
            .opacity(showExperience ? 1 : 0)
        }
        .animation(.easeOut(duration: 1.0), value: experienceProgress)
    }
    
    // MARK: - Level Up Section
    @ViewBuilder
    private var levelUpSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // 旧レベル
                levelBadge(level: oldLevel, isNew: false)
                
                // 矢印
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.white)
                    .scaleEffect(showLevelUp ? 1.0 : 0.1)
                
                // 新レベル
                levelBadge(level: newLevel, isNew: true)
            }
            
            Text("おめでとうございます！")
                .font(.headline)
                .foregroundColor(.white)
                .opacity(showLevelUp ? 1 : 0)
        }
        .scaleEffect(levelUpBounce)
        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: showLevelUp)
        .animation(.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0), value: levelUpBounce)
    }
    
    @ViewBuilder
    private func levelBadge(level: Int, isNew: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isNew ? Color.yellow : Color.white.opacity(0.3))
                .frame(width: 60, height: 60)
                .scaleEffect(isNew && showLevelUp ? 1.2 : 1.0)
            
            Text("\(level)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isNew ? .purple : .white)
        }
        .opacity(showLevelUp ? 1 : 0)
        .scaleEffect(showLevelUp ? 1.0 : 0.1)
    }
    
    // MARK: - Continue Button
    @ViewBuilder
    private var continueButton: some View {
        Button(action: {
            onAnimationComplete()
        }) {
            Text("続ける")
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
            ForEach(0..<(didLevelUp ? 12 : 6), id: \.self) { index in
                ExperienceStarParticle(
                    delay: Double(index) * 0.1,
                    isActive: showStars,
                    didLevelUp: didLevelUp
                )
            }
        }
    }
    
    // MARK: - Animation Sequence
    private func startAnimation() {
        // 1. 背景表示（即座に）
        showBackground = true
        
        // 2. メインアイコン表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps) {
            showMainIcon = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                iconScale = 1.0
            }
            if didLevelUp {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
        }
        
        // 3. 経験値表示
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 2) {
            showExperience = true
            withAnimation(.easeInOut(duration: 1.0)) {
                experienceProgress = 1.0
            }
        }
        
        // 4. レベルアップ表示（該当する場合）
        if didLevelUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 3) {
                showLevelUp = true
                showStars = true
                
                // バウンスエフェクト
                withAnimation(.spring(response: 0.4, dampingFraction: 0.3)) {
                    levelUpBounce = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        levelUpBounce = 1.0
                    }
                }
            }
        } else {
            // レベルアップしない場合は少ない星エフェクト
            DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenSteps * 2.5) {
                showStars = true
            }
        }
        
        // 5. 続行ボタン表示
        let finalDelay = didLevelUp ? delayBetweenSteps * 4 : delayBetweenSteps * 3
        DispatchQueue.main.asyncAfter(deadline: .now() + finalDelay) {
            showContinueButton = true
        }
    }
}

// MARK: - Experience Context
struct ExperienceContext {
    let title: String
    let subtitle: String
    let iconName: String
    
    static let cooking = ExperienceContext(
        title: "経験値獲得！",
        subtitle: "調理記録を保存しました",
        iconName: "checkmark.circle.fill"
    )
    
    static let recipe = ExperienceContext(
        title: "経験値獲得！",
        subtitle: "レシピを登録しました",
        iconName: "book.circle.fill"
    )
    
    static let achievement = ExperienceContext(
        title: "達成報酬！",
        subtitle: "目標を達成しました",
        iconName: "trophy.circle.fill"
    )
}

// MARK: - Experience Star Particle
struct ExperienceStarParticle: View {
    let delay: Double
    let isActive: Bool
    let didLevelUp: Bool
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(didLevelUp ? .title2 : .title3)
            .foregroundColor(didLevelUp ? .yellow : .orange)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                guard isActive else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let randomX = Double.random(in: -150...150)
                    let randomY = Double.random(in: -200...200)
                    
                    withAnimation(.easeOut(duration: 2.0)) {
                        offset = CGSize(width: randomX, height: randomY)
                        opacity = 0
                    }
                    
                    withAnimation(.easeOut(duration: 0.3)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeOut(duration: 1.5)) {
                            opacity = 0
                            scale = 0.1
                        }
                    }
                }
            }
    }
}

// MARK: - Preview
struct ExperienceChangeAnimation_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 通常の経験値獲得
            ExperienceChangeAnimation(
                experienceGained: 25,
                didLevelUp: false,
                oldLevel: 3,
                newLevel: 3,
                context: .cooking,
                onAnimationComplete: {}
            )
            .previewDisplayName("経験値獲得")
            
            // レベルアップ
            ExperienceChangeAnimation(
                experienceGained: 50,
                didLevelUp: true,
                oldLevel: 2,
                newLevel: 3,
                context: .cooking,
                onAnimationComplete: {}
            )
            .previewDisplayName("レベルアップ")
        }
    }
}