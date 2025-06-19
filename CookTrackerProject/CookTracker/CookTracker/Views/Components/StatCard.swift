//
//  StatCard.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI

/// 統計情報表示用の共通カードコンポーネント
/// - アイコン、タイトル、値、サブタイトルを統一されたレイアウトで表示
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            // アイコン
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            // タイトル
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            
            // 値
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // サブタイトル
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview
struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatCard(
                icon: "calendar.circle.fill",
                iconColor: .blue,
                title: "総調理日数",
                value: "25日",
                subtitle: "累計45回調理"
            )
            
            StatCard(
                icon: "flame.circle.fill",
                iconColor: .orange,
                title: "連続調理",
                value: "7日",
                subtitle: "最高14日"
            )
        }
        .padding()
    }
}