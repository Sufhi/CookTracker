// MARK: - Imports
import SwiftUI
import CoreData

/// 調理統計表示コンポーネント群
/// - 調理統計の計算と表示
/// - よく作るレシピの分析
/// - 統計情報のビジュアル化

// MARK: - Cooking Stats Section
struct CookingStatsSection: View {
    let records: [CookingRecord]
    
    private var averageCookingTime: Double {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + Int($1.cookingTimeInMinutes) }
        return Double(total) / Double(records.count)
    }
    
    private var totalCookingTime: Int {
        records.reduce(0) { $0 + Int($1.cookingTimeInMinutes) }
    }
    
    private var favoriteRecipes: [(String, Int)] {
        let grouped = Dictionary(grouping: records) { $0.recipe?.title ?? "不明" }
        let counts = grouped.mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("調理統計")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // 平均調理時間
                StatRowView(
                    icon: "clock",
                    title: "平均調理時間",
                    value: String(format: "%.1f分", averageCookingTime)
                )
                
                // 総調理時間
                StatRowView(
                    icon: "sum",
                    title: "総調理時間",
                    value: "\(totalCookingTime)分"
                )
                
                // よく作るレシピ
                if !favoriteRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.brown)
                            Text("よく作るレシピ")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        ForEach(Array(favoriteRecipes.enumerated()), id: \.offset) { index, recipe in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(recipe.0)
                                    .font(.caption)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(recipe.1)回")
                                    .font(.caption)
                                    .foregroundColor(.brown)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
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

// MARK: - Stat Row View
struct StatRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brown)
        }
    }
}

// MARK: - Preview
struct StatsComponents_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let records: [CookingRecord] = []
        
        VStack {
            CookingStatsSection(records: records)
            
            StatRowView(icon: "clock", title: "平均調理時間", value: "25.5分")
                .padding()
        }
        .environment(\.managedObjectContext, context)
    }
}