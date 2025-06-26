//
//  OnboardingView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI

/// アプリ初回起動時のオンボーディング画面
/// - 利用規約とプライバシーポリシーへの同意を求める
struct OnboardingView: View {
    @Binding var hasAcceptedTerms: Bool
    @State private var isAgreed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 40)
                    
                    // アプリアイコンとタイトル
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.brown)
                        
                        Text("CookTracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.brown)
                        
                        Text("料理を楽しく記録して\n調理スキルを向上させよう")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // 機能紹介
                    VStack(spacing: 24) {
                        FeatureRow(
                            icon: "book.fill",
                            title: "レシピ管理",
                            description: "お気に入りのレシピを簡単に保存・管理"
                        )
                        
                        FeatureRow(
                            icon: "timer",
                            title: "調理タイマー",
                            description: "調理時間を正確に測定してスキルアップ"
                        )
                        
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "成長記録",
                            description: "調理履歴で上達を実感できる"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            
            // 利用規約同意エリア
            VStack(spacing: 16) {
                Divider()
                
                VStack(spacing: 12) {
                    // 同意チェックボックス
                    HStack {
                        Button(action: {
                            isAgreed.toggle()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundColor(isAgreed ? .brown : .gray)
                                
                                Text("利用規約とプライバシーポリシーに同意する")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 開始ボタン
                    Button(action: {
                        hasAcceptedTerms = true
                    }) {
                        Text("はじめる！")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isAgreed ? Color.brown : Color.gray)
                            )
                    }
                    .disabled(!isAgreed)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // アイコン
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brown)
                .frame(width: 30, height: 30)
            
            // テキスト
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasAcceptedTerms: .constant(false))
    }
}