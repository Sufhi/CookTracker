//
//  ExperienceNotificationBar.swift
//  CookTracker
//
//  Created by Claude on 2025/06/21.
//

import SwiftUI

/// 経験値獲得通知バー
/// - ホーム画面上部に一時的に表示される通知
/// - 経験値獲得とレベルアップを表示
struct ExperienceNotificationBar: View {
    
    // MARK: - Properties
    let experienceGained: Int
    let didLevelUp: Bool
    let oldLevel: Int
    let newLevel: Int
    let onDismiss: () -> Void
    
    @State private var isVisible = true
    @State private var offset: CGFloat = -100
    
    private let displayDuration: Double = 4.0
    private let animationDuration: Double = 0.8
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                notificationContent
                    .offset(y: offset)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: animationDuration, dampingFraction: 0.8), value: offset)
                    .onAppear {
                        startNotificationSequence()
                    }
            }
        }
    }
    
    // MARK: - Notification Content
    @ViewBuilder
    private var notificationContent: some View {
        HStack(spacing: 12) {
            // アイコン
            notificationIcon
            
            // 内容
            notificationText
            
            Spacer()
            
            // 閉じるボタン
            dismissButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(notificationBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var notificationIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 40)
            
            Image(systemName: didLevelUp ? "star.fill" : "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var notificationText: some View {
        VStack(alignment: .leading, spacing: 2) {
            if didLevelUp {
                Text("レベルアップ！")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Lv.\(oldLevel) → Lv.\(newLevel)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            } else {
                Text("経験値獲得！")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("+\(experienceGained) XP")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .fontWeight(.medium)
            }
        }
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        Button(action: {
            dismissNotification()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Styling
    private var notificationBackgroundColor: LinearGradient {
        if didLevelUp {
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.brown.opacity(0.9), Color.orange.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Animation Control
    private func startNotificationSequence() {
        // 1. スライドイン
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: animationDuration, dampingFraction: 0.8)) {
                offset = 0
            }
        }
        
        // 2. 自動消去
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            dismissNotification()
        }
    }
    
    private func dismissNotification() {
        withAnimation(.spring(response: animationDuration, dampingFraction: 0.8)) {
            offset = -100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isVisible = false
            onDismiss()
        }
    }
    
    // MARK: - Public Methods
    func show() {
        isVisible = true
    }
}

// MARK: - Preview
struct ExperienceNotificationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // 通常の経験値獲得
            ExperienceNotificationBar(
                experienceGained: 25,
                didLevelUp: false,
                oldLevel: 2,
                newLevel: 2,
                onDismiss: {}
            )
            .onAppear {
                // Preview用の表示トリガー
            }
            
            Spacer()
            
            // レベルアップ
            ExperienceNotificationBar(
                experienceGained: 50,
                didLevelUp: true,
                oldLevel: 2,
                newLevel: 3,
                onDismiss: {}
            )
            .onAppear {
                // Preview用の表示トリガー
            }
            
            Spacer()
        }
        .previewDisplayName("通知バー")
    }
}