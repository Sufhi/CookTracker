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
    @State private var currentUser: User?
    @StateObject private var badgeSystem = BadgeSystem.shared
    
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
                    
                    // バッジタブ
                    badgeTabView
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("履歴・統計")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadUserData()
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
                if let user = currentUser {
                    // ユーザー統計カード
                    UserStatsCard(
                        user: user, 
                        totalRecords: cookingRecords.count,
                        cookingRecords: Array(cookingRecords)
                    )
                    
                    // 調理統計
                    CookingStatsSection(records: Array(cookingRecords))
                    
                    // 月間カレンダー
                    MonthlyCalendarView(records: Array(cookingRecords))
                } else {
                    Text("データを読み込み中...")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var badgeTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let user = currentUser {
                    BadgeListView(user: user)
                } else {
                    Text("データを読み込み中...")
                        .foregroundColor(.secondary)
                }
            }
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
    private func loadUserData() {
        currentUser = PersistenceController.shared.getOrCreateDefaultUser()
    }
    
    /// 連続調理日数を計算
    private func calculateConsecutiveDays() -> Int {
        let sortedRecords = cookingRecords.sorted { record1, record2 in
            (record1.cookedAt ?? Date.distantPast) > (record2.cookedAt ?? Date.distantPast)
        }
        
        guard !sortedRecords.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var consecutiveDays = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // 昨日から逆順にチェック
        var checkDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        
        while checkDate != nil {
            let checkingDate = checkDate!
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
    case history, stats, badges
    
    var title: String {
        switch self {
        case .history: return "履歴"
        case .stats: return "統計"
        case .badges: return "バッジ"
        }
    }
    
    var iconName: String {
        switch self {
        case .history: return "clock"
        case .stats: return "chart.bar"
        case .badges: return "trophy"
        }
    }
}

// MARK: - History Day Section
struct HistoryDaySection: View {
    let date: Date
    let records: [CookingRecord]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 (E)"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 日付ヘッダー
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                Spacer()
                
                Text("\(records.count)件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // レコード一覧
            VStack(spacing: 8) {
                ForEach(records, id: \.id) { record in
                    HistoryRecordRow(record: record)
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

// MARK: - History Record Row
struct HistoryRecordRow: View {
    let record: CookingRecord
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // レシピアイコン
            Circle()
                .fill(Color.brown.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundColor(.brown)
                )
            
            // レシピ情報
            VStack(alignment: .leading, spacing: 4) {
                Text(record.recipe?.title ?? "不明なレシピ")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    if let cookedAt = record.cookedAt {
                        Text(timeFormatter.string(from: cookedAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(record.formattedCookingTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 経験値・写真情報
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(record.experienceGained) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                
                if let photoPaths = record.photoPaths as? [String], !photoPaths.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "camera.fill")
                            .font(.caption2)
                        Text("\(photoPaths.count)")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - User Stats Card
struct UserStatsCard: View {
    let user: User
    let totalRecords: Int
    let cookingRecords: [CookingRecord]
    
    var body: some View {
        VStack(spacing: 16) {
            // ユーザーレベル情報
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("レベル \(Int(user.level))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("経験値: \(Int(user.experiencePoints)) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // レベルアップ進捗
                VStack(alignment: .trailing, spacing: 4) {
                    Text("次のレベルまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(user.experienceToNextLevel)) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                }
            }
            
            // 進捗バー
            ProgressView(value: user.progressToNextLevel, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Divider()
            
            // 統計情報
            HStack {
                StatItemView(
                    icon: "fork.knife",
                    title: "総調理回数",
                    value: "\(totalRecords)回"
                )
                
                Spacer()
                
                StatItemView(
                    icon: "trophy.fill",
                    title: "獲得バッジ",
                    value: "\((user.badges as? Set<Badge>)?.count ?? 0)個"
                )
                
                Spacer()
                
                StatItemView(
                    icon: "calendar",
                    title: "連続記録",
                    value: "\(CookingStats.currentStreakDays(from: Array(cookingRecords)))日"
                )
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

// MARK: - Stat Item View
struct StatItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brown)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

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

// MARK: - Monthly Calendar View
struct MonthlyCalendarView: View {
    let records: [CookingRecord]
    @State private var selectedDate = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var recordDates: Set<Date> {
        Set(records.compactMap { record in
            guard let date = record.cookedAt else { return nil }
            return calendar.startOfDay(for: date)
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("調理カレンダー")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 簡易カレンダー（月表示）
            VStack(spacing: 12) {
                // 月年表示
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.brown)
                    }
                    
                    Spacer()
                    
                    Text(monthYearText)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.brown)
                    }
                }
                
                // 曜日ヘッダー
                HStack {
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 日付グリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(calendarDays, id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month),
                            hasRecord: recordDates.contains(date)
                        )
                    }
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
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date] = []
        for i in 0..<42 { // 6週間分
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let hasRecord: Bool
    
    private var dayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(hasRecord ? Color.brown.opacity(0.2) : Color.clear)
                .frame(width: 32, height: 32)
            
            if hasRecord {
                Circle()
                    .stroke(Color.brown, lineWidth: 2)
                    .frame(width: 32, height: 32)
            }
            
            Text(dayText)
                .font(.caption)
                .fontWeight(hasRecord ? .semibold : .regular)
                .foregroundColor(isCurrentMonth ? (hasRecord ? .brown : .primary) : .secondary)
        }
        .frame(height: 32)
    }
}

// MARK: - Preview
struct HistoryStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryStatsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}