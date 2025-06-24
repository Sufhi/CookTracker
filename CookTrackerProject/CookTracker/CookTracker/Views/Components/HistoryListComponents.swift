// MARK: - Imports
import SwiftUI
import CoreData

/// 調理履歴リスト表示コンポーネント群
/// - 日付別の履歴グループ化
/// - 個別の調理記録表示
/// - 経験値・写真情報の表示

// MARK: - History Day Section
struct HistoryDaySection: View {
    let date: Date
    let records: [CookingRecord]
    let onRecordTap: (CookingRecord) -> Void
    
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
                    HistoryRecordRow(record: record, onTap: onRecordTap)
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
    let onTap: (CookingRecord) -> Void
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        Button {
            onTap(record)
        } label: {
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
                        .foregroundColor(.primary)
                    
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
                
                // タップ可能を示すアイコン
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct HistoryListComponents_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        return VStack {
            HistoryDaySection(date: Date(), records: []) { _ in }
            
            Text("Preview Content")
                .padding()
        }
        .environment(\.managedObjectContext, context)
    }
}