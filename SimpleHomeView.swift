// MARK: - Imports
import SwiftUI

/// 基本的なホーム画面（Core Dataなし版）
/// - レベル・経験値の静的表示
/// - クイックアクションボタン
struct SimpleHomeView: View {
    
    // MARK: - Properties
    @State private var isShowingAddRecipe = false
    @State private var isShowingTimer = false
    
    // 静的なデータ（後でCore Dataに置き換え）
    private let currentLevel = 3
    private let currentExperience = 150
    private let experienceToNextLevel = 150
    private let progressToNextLevel = 0.5
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ユーザー情報・レベル表示セクション
                userInfoSection
                
                // 今日の調理提案セクション
                todaysSuggestionSection
                
                // クイックアクションボタンセクション
                quickActionSection
                
                // 最近の料理履歴セクション
                recentHistorySection
            }
            .padding()
        }
        .navigationTitle("CookTracker")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isShowingAddRecipe) {
            AddRecipeSheetView()
        }
        .sheet(isPresented: $isShowingTimer) {
            TimerSheetView()
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var userInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("レベル \(currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("経験値: \(currentExperience) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("次のレベルまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(experienceToNextLevel) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
            }
            
            // 経験値プログレスバー
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("レベル \(currentLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("レベル \(currentLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progressToNextLevel, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var todaysSuggestionSection: some View {
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
                    Text("簡単オムライス")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("難易度: ⭐⭐")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("予想時間: 20分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("調理開始") {
                    isShowingTimer = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.brown)
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
    
    @ViewBuilder
    private var quickActionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイックアクション")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: {
                    isShowingAddRecipe = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ追加")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isShowingTimer = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("タイマー")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // レシピ一覧は後で実装
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ一覧")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var recentHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.brown)
                Text("最近の料理履歴")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // サンプルデータ
            VStack(spacing: 8) {
                recentRecordRow(title: "オムライス", date: "06/13", exp: 15, time: 22)
                recentRecordRow(title: "味噌汁", date: "06/12", exp: 10, time: 8)
                recentRecordRow(title: "焼きそば", date: "06/11", exp: 12, time: 15)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private func recentRecordRow(title: String, date: String, exp: Int, time: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brown.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(.brown)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(exp) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                Text("\(time)分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sheet Views
struct AddRecipeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("調理タイマー")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("タイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SimpleHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleHomeView()
        }
    }
}