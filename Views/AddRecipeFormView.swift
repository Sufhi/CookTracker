// MARK: - Imports
import SwiftUI

/// レシピ追加・編集フォーム画面
/// - 手動入力とURL入力の両方に対応
/// - バリデーション機能付き
struct AddRecipeFormView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var inputMode: InputMode = .manual
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var url = ""
    @State private var category = "食事"
    @State private var difficulty = 1
    @State private var estimatedTime = 15
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 追加されたレシピを親ビューに通知するためのクロージャ
    let onRecipeAdded: (SampleRecipe) -> Void
    
    private let categories = ["食事", "デザート", "おつまみ", "その他"]
    
    // MARK: - Input Mode
    enum InputMode: String, CaseIterable {
        case manual = "手動入力"
        case url = "URL登録"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // 入力モード選択
                inputModeSection
                
                // 基本情報セクション
                basicInfoSection
                
                // 詳細情報セクション
                detailsSection
                
                // 追加ボタンセクション
                addButtonSection
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
            .alert("入力エラー", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var inputModeSection: some View {
        Section("入力方法") {
            Picker("入力モード", selection: $inputMode) {
                ForEach(InputMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
        Section("基本情報") {
            if inputMode == .url {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("YouTube/WebサイトのURL", text: $url)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    Text("URLを入力後、タイトルを手動で入力してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            TextField("レシピ名 *", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section("詳細情報") {
            VStack(alignment: .leading, spacing: 8) {
                Text("材料 *")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $ingredients)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if ingredients.isEmpty {
                    Text("例: 卵 2個\nご飯 200g\nケチャップ 大さじ2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("作り方")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $instructions)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if instructions.isEmpty {
                    Text("例: 1. 材料を切る\n2. フライパンで炒める\n3. 味付けをする")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Picker("カテゴリ", selection: $category) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("難易度: \(String(repeating: "⭐", count: difficulty))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Slider(value: Binding(
                    get: { Double(difficulty) },
                    set: { difficulty = Int($0) }
                ), in: 1...5, step: 1)
                .accentColor(.brown)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("予想調理時間: \(estimatedTime)分")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Slider(value: Binding(
                    get: { Double(estimatedTime) },
                    set: { estimatedTime = Int($0) }
                ), in: 5...120, step: 5)
                .accentColor(.brown)
            }
        }
    }
    
    @ViewBuilder
    private var addButtonSection: some View {
        Section {
            Button(action: addRecipe) {
                HStack {
                    Spacer()
                    Text("レシピを追加")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFormValid ? Color.brown : Color.gray)
                )
            }
            .disabled(!isFormValid)
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Methods
    private func addRecipe() {
        // バリデーション
        guard isFormValid else {
            alertMessage = "レシピ名と材料は必須項目です"
            showingAlert = true
            return
        }
        
        // URL入力モードの場合のバリデーション
        if inputMode == .url && !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if !isValidURL(url) {
                alertMessage = "有効なURLを入力してください"
                showingAlert = true
                return
            }
        }
        
        // 新しいレシピを作成
        let newRecipe = SampleRecipe(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            difficulty: difficulty,
            estimatedTime: estimatedTime,
            createdAt: Date()
        )
        
        // 親ビューに通知
        onRecipeAdded(newRecipe)
        
        // 画面を閉じる
        dismiss()
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
}

// MARK: - Preview
struct AddRecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeFormView { _ in
            // プレビュー用の空のクロージャ
        }
    }
}