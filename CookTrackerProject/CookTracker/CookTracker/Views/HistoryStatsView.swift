// MARK: - Imports
import SwiftUI
import CoreData

/// 調理履歴・統計画面
/// - 調理記録の一覧表示
/// - 統計情報の表示
/// - バッジ一覧
/// - カレンダー表示
struct HistoryStatsView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var isShowingSettings = false
    
    // Core Data取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)],
        animation: .default
    ) private var cookingRecords: FetchedResults<CookingRecord>
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // タブ選択
                tabSelector
                
                // タブコンテンツ
                TabView(selection: $selectedTab) {
                    // 履歴タブ
                    historyTabView
                        .tag(0)
                    
                    // 統計タブ
                    statsTabView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("履歴・統計")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabType.allCases.enumerated()), id: \.offset) { index, tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 18, weight: .medium))
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? .brown : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGroupedBackground))
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var historyTabView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if cookingRecords.isEmpty {
                    emptyHistoryView
                } else {
                    ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                        HistoryDaySection(
                            date: date,
                            records: groupedRecords[date] ?? []
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var statsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ユーザー統計カード
                UserStatusCard.forStats(
                    totalRecords: cookingRecords.count,
                    cookingRecords: Array(cookingRecords)
                )
                
                // 調理統計
                CookingStatsSection(records: Array(cookingRecords))
                
                // 月間カレンダー
                MonthlyCalendarView(records: Array(cookingRecords))
            }
            .padding()
        }
    }
    
    
    @ViewBuilder
    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.brown.opacity(0.5))
            
            Text("調理履歴がありません")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("料理を作って記録を残しましょう！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    private var groupedRecords: [Date: [CookingRecord]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: cookingRecords) { record in
            guard let date = record.cookedAt else { return Date() }
            return calendar.startOfDay(for: date)
        }
        return grouped
    }
    
    // MARK: - Methods
    
    /// 連続調理日数を計算
    private func calculateConsecutiveDays() -> Int {
        let sortedRecords = cookingRecords.sorted { record1, record2 in
            (record1.cookedAt ?? Date.distantPast) > (record2.cookedAt ?? Date.distantPast)
        }
        
        guard !sortedRecords.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var consecutiveDays = 0
        let currentDate = calendar.startOfDay(for: Date())
        
        // 昨日から逆順にチェック
        var checkDate = calendar.date(byAdding: .day, value: -1, to: currentDate)
        
        while let checkingDate = checkDate {
            let startOfDay = calendar.startOfDay(for: checkingDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // その日に調理記録があるかチェック
            let recordsOnDate = sortedRecords.filter { record in
                guard let cookedAt = record.cookedAt else { return false }
                return cookedAt >= startOfDay && cookedAt < endOfDay
            }
            
            if !recordsOnDate.isEmpty {
                consecutiveDays += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkingDate)
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
}

// MARK: - Tab Type
enum TabType: CaseIterable {
    case history, stats
    
    var title: String {
        switch self {
        case .history: return "履歴"
        case .stats: return "統計"
        }
    }
    
    var iconName: String {
        switch self {
        case .history: return "clock"
        case .stats: return "chart.bar"
        }
    }
}

// MARK: - Preview
struct HistoryStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryStatsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
