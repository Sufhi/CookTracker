// MARK: - Imports
import SwiftUI
import CoreData

/// ユーザーステータス表示の共通コンポーネント
/// - レベル・経験値・進捗バーの統一表示
/// - Core Dataとの自動同期
/// - 単一責任: ユーザーステータスの表示のみ
struct UserStatusCard: View {
    
    // MARK: - Properties
    let showDetailedStats: Bool
    let additionalContent: (() -> AnyView)?
    
    // Core Data - ユーザー情報を自動取得・更新
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.updatedAt, ascending: false)],
        animation: .default
    ) private var users: FetchedResults<User>
    
    // MARK: - Computed Properties
    private var currentUser: User? {
        return users.first ?? PersistenceController.shared.getOrCreateDefaultUser()
    }
    
    private var userLevel: Int {
        return Int(currentUser?.level ?? 1)
    }
    
    private var userExperience: Int {
        return Int(currentUser?.experiencePoints ?? 0)
    }
    
    private var userExperienceToNext: Int {
        return Int(currentUser?.experienceToNextLevel ?? 150)
    }
    
    private var userProgress: Double {
        return currentUser?.progressToNextLevel ?? 0.0
    }
    
    // MARK: - Initializers
    init(showDetailedStats: Bool = false, @ViewBuilder additionalContent: @escaping () -> AnyView = { AnyView(EmptyView()) }) {
        self.showDetailedStats = showDetailedStats
        self.additionalContent = additionalContent
    }
    
    init(showDetailedStats: Bool = false) {
        self.showDetailedStats = showDetailedStats
        self.additionalContent = nil
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // レベル・経験値情報
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("レベル \(userLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("経験値: \(userExperience) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("次のレベルまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(userExperienceToNext) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
            }
            
            // 進捗バー
            VStack(alignment: .leading, spacing: 4) {
                if showDetailedStats {
                    HStack {
                        Text("レベル \(userLevel)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("レベル \(userLevel + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ProgressView(value: userProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .animation(.easeInOut(duration: 0.5), value: userProgress)
            }
            
            // 追加コンテンツ
            if let additionalContent = additionalContent {
                Divider()
                additionalContent()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Convenience Extensions
extension UserStatusCard {
    
    /// ホーム画面用の簡潔版
    static func forHome() -> UserStatusCard {
        return UserStatusCard(showDetailedStats: true)
    }
    
    /// 統計画面用の詳細版（追加統計付き）
    static func forStats(
        totalRecords: Int,
        cookingRecords: [CookingRecord]
    ) -> UserStatusCard {
        return UserStatusCard(showDetailedStats: false) {
            AnyView(
                HStack {
                    StatCard(
                        icon: "fork.knife",
                        iconColor: .brown,
                        title: "総調理回数",
                        value: "\(totalRecords)",
                        subtitle: "回"
                    )
                    
                    Spacer()
                    
                    StatCard(
                        icon: "calendar",
                        iconColor: .brown,
                        title: "連続クッキング",
                        value: "\(CookingStats.currentStreakDays(from: cookingRecords))",
                        subtitle: "日"
                    )
                    
                    Spacer()
                    
                    StatCard(
                        icon: "clock.arrow.circlepath",
                        iconColor: .brown,
                        title: "平均時間",
                        value: String(format: "%.0f", cookingRecords.isEmpty ? 0 : Double(cookingRecords.reduce(0) { $0 + Int($1.cookingTimeInMinutes) }) / Double(cookingRecords.count)),
                        subtitle: "分"
                    )
                }
            )
        }
    }
}

// MARK: - Preview
struct UserStatusCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // ホーム用
            UserStatusCard.forHome()
            
            // 統計用
            UserStatusCard.forStats(totalRecords: 42, cookingRecords: [])
        }
        .padding()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}