// MARK: - Imports
import SwiftUI
import CoreData

/// レシピ一覧を表示するメインビュー
/// - レシピの検索・フィルター機能を提供
/// - タップでレシピ詳細画面に遷移
struct RecipeListView: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedCategory = "全て"
    @State private var isShowingAddRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    
    // Core Data取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    private let categories = ["全て", "食事", "デザート", "おつまみ"]
    
    // MARK: - Computed Properties
    private var filteredRecipes: [Recipe] {
        let allRecipes = Array(recipes)
        let categoryFiltered = selectedCategory == "全て" ? allRecipes : allRecipes.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { recipe in
                (recipe.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                (recipe.ingredients ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                searchSection
                
                // カテゴリフィルター
                categorySection
                
                // レシピ一覧
                recipeListSection
            }
            .navigationTitle("レシピ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddRecipe) {
                RecipeFormView()
            }
            .sheet(item: $selectedRecipe) { recipe in
                CoreDataRecipeDetailView(recipe: recipe)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("レシピを検索...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .foregroundColor(selectedCategory == category ? .white : .brown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.brown : Color.brown.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var recipeListSection: some View {
        if filteredRecipes.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピが見つかりません")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("新しいレシピを追加してください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("レシピを追加") {
                    isShowingAddRecipe = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        } else {
            List {
                ForEach(filteredRecipes, id: \.id) { recipe in
                    CoreDataRecipeRowView(recipe: recipe) {
                        selectedRecipe = recipe
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    // MARK: - Methods
    
    /// レシピ削除
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            PersistenceController.shared.save()
        }
    }
}


// MARK: - Sample Recipe Model
struct SampleRecipe: Identifiable {
    let id: UUID
    let title: String
    let ingredients: String
    let instructions: String
    let category: String
    let difficulty: Int
    let estimatedTime: Int
    let createdAt: Date
}

// MARK: - Add Recipe View
struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("この機能は次のステップで実装予定です")
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

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: SampleRecipe
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cookingSession = CookingSessionTimer()
    @State private var isShowingCookingView = false
    @State private var completedRecord: CookingSessionRecord?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(recipe.estimatedTime)分", systemImage: "clock")
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("難易度:")
                                ForEach(0..<5) { index in
                                    Image(systemName: index < recipe.difficulty ? "star.fill" : "star")
                                        .foregroundColor(index < recipe.difficulty ? .brown : .gray.opacity(0.3))
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("材料")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.ingredients)
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作り方")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.instructions)
                            .font(.body)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("レシピ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingCookingView) {
                CookingSessionView(
                    recipe: recipe,
                    cookingSession: cookingSession,
                    helperTimer: nil
                ) { record in
                    completedRecord = record
                    // 将来: Core Dataに保存
                    print("✅ 調理記録保存: \(record.formattedActualTime)")
                }
            }
        }
    }
}

// MARK: - Simple Add Recipe View
struct SimpleAddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var ingredients = ""
    @State private var category = "食事"
    
    let onRecipeAdded: (SampleRecipe) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("レシピ名", text: $title)
                    
                    Picker("カテゴリ", selection: $category) {
                        Text("食事").tag("食事")
                        Text("デザート").tag("デザート")
                        Text("おつまみ").tag("おつまみ")
                    }
                }
                
                Section("材料") {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("レシピを追加") {
                        let newRecipe = SampleRecipe(
                            id: UUID(),
                            title: title,
                            ingredients: ingredients,
                            instructions: "",
                            category: category,
                            difficulty: 2,
                            estimatedTime: 20,
                            createdAt: Date()
                        )
                        onRecipeAdded(newRecipe)
                        dismiss()
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
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


// MARK: - Core Data Recipe Detail View
struct CoreDataRecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var sessionManager: CookingSessionManager
    @State private var isShowingCookingView = false
    @State private var isShowingEditView = false
    @State private var currentUser: User?
    @State private var selectedCookingRecord: CookingRecord?
    @State private var isShowingFullHistory = false
    @State private var isShowingImagePicker = false
    @State private var selectedThumbnailImage: UIImage?
    
    // このレシピの調理記録を取得
    var cookingRecords: [CookingRecord] {
        guard let recipeId = recipe.id else { return [] }
        
        let request: NSFetchRequest<CookingRecord> = CookingRecord.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %@", recipeId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CookingRecord.cookedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            AppLogger.coreDataError("調理履歴取得", error: error)
            return []
        }
    }
    
    // 改善メモのある調理記録を取得
    var improvementNotes: [CookingRecord] {
        return cookingRecords.filter { record in
            guard let notes = record.notes, !notes.isEmpty else { return false }
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 調理中の場合は調理中カード、そうでなければ調理開始ボタンを表示
                    if sessionManager.isCurrentlyCooking {
                        CookingSessionActiveCard(onSessionTap: {
                            isShowingCookingView = true
                        })
                    } else {
                        // 調理開始ボタン（おしゃれなデザイン）
                        Button(action: {
                            let _ = sessionManager.startCookingSession(for: recipe)
                            isShowingCookingView = true
                        }) {
                            HStack(spacing: 12) {
                                // アイコン
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                // テキスト
                                Text("調理を開始する")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // 右側のアイコン
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.brown]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.brown.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // ヘッダー情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title ?? "無題のレシピ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(Int(recipe.estimatedTimeInMinutes))分", systemImage: "clock")
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("難易度:")
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(recipe.difficulty) ? "star.fill" : "star")
                                        .foregroundColor(index < Int(recipe.difficulty) ? .brown : .gray.opacity(0.3))
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(recipe.category ?? "食事")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.brown)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.brown.opacity(0.1))
                            )
                    }
                    
                    Divider()
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("材料")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.ingredients ?? "材料なし")
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作り方")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.instructions ?? "手順なし")
                            .font(.body)
                    }
                    
                    // URL（ある場合）
                    if let urlString = recipe.url, !urlString.isEmpty, let url = URL(string: urlString) {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("参考URL")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Link(urlString, destination: url)
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("レシピ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingCookingView) {
                if let currentRecipe = sessionManager.currentRecipe,
                   let currentSession = sessionManager.currentSession {
                    CookingSessionView(
                        recipe: RecipeConverter.toSampleRecipe(currentRecipe),
                        cookingSession: currentSession,
                        onCookingComplete: { sampleRecord in
                            print("✅ 調理記録保存: \(sampleRecord.formattedActualTime)")
                            sessionManager.finishCookingSession()
                        },
                        helperTimer: sessionManager.sharedHelperTimer
                    )
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                RecipeFormView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("編集", action: {
                            isShowingEditView = true
                        })
                        
                        Divider()
                        
                        Button("サムネイル選択", action: {
                            isShowingImagePicker = true
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                currentUser = PersistenceController.shared.getOrCreateDefaultUser()
            }
            .sheet(item: $selectedCookingRecord) { record in
                CookingRecordDetailView(cookingRecord: record)
            }
            .sheet(isPresented: $isShowingFullHistory) {
                RecipeCookingHistoryView(recipe: recipe)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(
                    selectedImage: $selectedThumbnailImage,
                    hasCurrentImage: recipe.hasThumbnail,
                    onSave: { image in
                        saveThumbnail(image)
                    }
                )
            }
        }
    }
    
    private func saveThumbnail(_ image: UIImage?) {
        if let image = image {
            // 画像を保存
            if recipe.saveThumbnailImage(image) {
                do {
                    try viewContext.save()
                    print("✅ サムネイル保存成功")
                } catch {
                    print("❌ サムネイル保存エラー: \(error)")
                }
            }
        } else {
            // 画像を削除
            recipe.deleteThumbnailImage()
            do {
                try viewContext.save()
                print("✅ サムネイル削除成功")
            } catch {
                print("❌ サムネイル削除エラー: \(error)")
            }
        }
        selectedThumbnailImage = nil
    }
    
    
    // MARK: - View Components
    @ViewBuilder
    private var improvementNotesSection: some View {
        if !improvementNotes.isEmpty {
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("改善メモ")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(improvementNotes.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(improvementNotes.prefix(3), id: \.id) { record in
                        improvementNoteRow(record: record)
                    }
                    
                    if improvementNotes.count > 3 {
                        Button("すべての改善メモを表示 (\(improvementNotes.count)件)") {
                            isShowingFullHistory = true
                        }
                        .font(.caption)
                        .foregroundColor(.brown)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func improvementNoteRow(record: CookingRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // メモ内容
            Text(record.notes ?? "")
                .font(.body)
                .foregroundColor(.primary)
            
            // 記入日時
            if let cookedAt = record.cookedAt {
                Text(formatDetailedDate(cookedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    @ViewBuilder
    private var cookingHistorySection: some View {
        if !cookingRecords.isEmpty {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("調理履歴")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(cookingRecords.count)回")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(cookingRecords.prefix(5), id: \.id) { record in
                        cookingHistoryRow(record: record)
                    }
                    
                    if cookingRecords.count > 5 {
                        Button("すべて表示 (\(cookingRecords.count)件)") {
                            isShowingFullHistory = true
                        }
                        .font(.caption)
                        .foregroundColor(.brown)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cookingHistoryRow(record: CookingRecord) -> some View {
        Button(action: {
            selectedCookingRecord = record
        }) {
            HStack(spacing: 12) {
                // 調理日のアイコン
                Circle()
                    .fill(Color.brown.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(Calendar.current.component(.day, from: record.cookedAt ?? Date()))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(formatDate(record.cookedAt ?? Date()))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(record.cookingTimeInMinutes))分")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = record.notes, !notes.isEmpty {
                        Text(notes.prefix(30) + (notes.count > 30 ? "..." : ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Text("+\(Int(record.experienceGained)) XP")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                        
                        if hasPhotos(record) {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.brown)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDetailedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
    
    private func hasPhotos(_ record: CookingRecord) -> Bool {
        guard let photoPaths = record.photoPaths as? [String] else { return false }
        return !photoPaths.isEmpty
    }
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
