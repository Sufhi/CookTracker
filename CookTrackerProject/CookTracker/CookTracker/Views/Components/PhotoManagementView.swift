// MARK: - Imports
import SwiftUI
import PhotosUI

/// 写真管理機能を提供するコンポーネント
/// - 写真選択・撮影機能
/// - 写真表示・削除機能
/// - 最大20枚制限管理
struct PhotoManagementView: View {
    @Binding var photoImages: [UIImage]
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isShowingCamera = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("完成写真")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 写真表示グリッド
            if !photoImages.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                            
                            Button(action: {
                                photoImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .offset(x: 5, y: -5)
                        }
                    }
                }
            }
            
            // 写真追加ボタン
            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 20 - photoImages.count,
                    matching: .images
                ) {
                    Label("写真を選択", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isShowingCamera = true
                }) {
                    Label("カメラで撮影", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
            
            Text("最大20枚まで保存できます（現在: \(photoImages.count)/20）")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .onChange(of: selectedPhotos) { _, _ in
            loadSelectedPhotos()
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView { image in
                photoImages.append(image)
            }
        }
    }
    
    // MARK: - Methods
    
    /// 選択した写真を読み込み
    private func loadSelectedPhotos() {
        Task {
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        photoImages.append(image)
                    }
                }
            }
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
    }
}

// MARK: - Preview
struct PhotoManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoManagementView(photoImages: .constant([]))
            .padding()
    }
}