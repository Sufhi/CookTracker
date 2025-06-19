import SwiftUI
import PhotosUI

/// レシピサムネイル選択用のImagePicker
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var tempImage: UIImage?
    @State private var hasChanges = false
    let hasCurrentImage: Bool
    let onSave: (UIImage?) -> Void
    
    init(selectedImage: Binding<UIImage?>, hasCurrentImage: Bool = false, onSave: @escaping (UIImage?) -> Void) {
        self._selectedImage = selectedImage
        self.hasCurrentImage = hasCurrentImage
        self.onSave = onSave
        self._tempImage = State(initialValue: selectedImage.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let tempImage = tempImage {
                    // 選択された画像のプレビュー
                    Image(uiImage: tempImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    // プレースホルダー
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("サムネイル画像を選択")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("レシピのサムネイル画像を選択してください")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        )
                }
                
                // アクションボタンセクション
                VStack(spacing: 12) {
                    // 写真選択ボタン
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("写真を選択", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                tempImage = image
                                hasChanges = true
                            }
                        }
                    }
                    
                    // サムネイル削除ボタン（現在のサムネイルがある場合のみ表示）
                    if hasCurrentImage {
                        Button(action: {
                            tempImage = nil
                            hasChanges = true
                        }) {
                            Label("サムネイルを削除", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("サムネイル選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        // 変更があった場合のみ保存を実行
                        if hasChanges {
                            onSave(tempImage)
                        }
                        dismiss()
                    }
                    .disabled(!hasChanges)
                }
            }
        }
    }
}

/// UIImagePickerControllerベースのImagePicker（iOS 14対応）
struct LegacyImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: LegacyImagePicker
        
        init(_ parent: LegacyImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ImagePicker(selectedImage: .constant(nil), hasCurrentImage: false, onSave: { _ in })
}