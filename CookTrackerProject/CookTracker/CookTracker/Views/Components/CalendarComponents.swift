// MARK: - Imports
import SwiftUI
import CoreData

/// 調理カレンダー表示コンポーネント群
/// - 月次カレンダー表示
/// - 調理記録の可視化
/// - 日付ナビゲーション機能

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
struct CalendarComponents_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let records: [CookingRecord] = []
        
        VStack {
            MonthlyCalendarView(records: records)
            
            CalendarDayView(date: Date(), isCurrentMonth: true, hasRecord: true)
                .padding()
        }
        .environment(\.managedObjectContext, context)
    }
}