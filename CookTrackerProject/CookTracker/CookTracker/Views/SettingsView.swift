//
//  SettingsView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI
import MessageUI

/// アプリ設定画面
/// - 利用規約、プライバシーポリシー、問い合わせなどApp Store準拠の設定項目
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingTermsOfService = false
    @State private var isShowingPrivacyPolicy = false
    @State private var isShowingMailComposer = false
    @State private var showingMailError = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            List {
                // アプリ情報セクション
                Section {
                    HStack {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.brown)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CookTracker")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("料理記録アプリ")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("バージョン \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 法的情報セクション
                Section("法的情報") {
                    Button(action: {
                        isShowingTermsOfService = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.brown)
                                .frame(width: 24)
                            
                            Text("利用規約")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        isShowingPrivacyPolicy = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.brown)
                                .frame(width: 24)
                            
                            Text("プライバシーポリシー")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // サポートセクション
                Section("サポート") {
                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailComposer = true
                        } else {
                            showingMailError = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.brown)
                                .frame(width: 24)
                            
                            Text("お問い合わせ")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        openAppStore()
                    }) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.brown)
                                .frame(width: 24)
                            
                            Text("App Storeでレビュー")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // その他セクション
                Section("その他") {
                    Button(action: {
                        shareApp()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.brown)
                                .frame(width: 24)
                            
                            Text("アプリを共有")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingTermsOfService) {
            LegalDocumentView(
                title: "利用規約",
                htmlFileName: "terms_of_service"
            )
        }
        .sheet(isPresented: $isShowingPrivacyPolicy) {
            LegalDocumentView(
                title: "プライバシーポリシー", 
                htmlFileName: "privacy_policy"
            )
        }
        .sheet(isPresented: $isShowingMailComposer) {
            MailComposeView()
        }
        .alert("メール送信エラー", isPresented: $showingMailError) {
            Button("OK") { }
        } message: {
            Text("お使いのデバイスでメール送信が設定されていません。")
        }
    }
    
    // MARK: - Helper Methods
    
    private func openAppStore() {
        // 実際のApp Store URLに置き換え
        if let url = URL(string: "https://apps.apple.com/jp/app/cooktracker/id123456789") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        let shareText = "CookTracker - 料理を楽しく記録するアプリ"
        let shareURL = URL(string: "https://apps.apple.com/jp/app/cooktracker/id123456789")
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText, shareURL].compactMap { $0 },
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}


// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject("CookTrackerアプリについて")
        composer.setToRecipients(["support@cooktracker.app"])
        
        let deviceInfo = """
        
        ---
        デバイス情報:
        iOS: \(UIDevice.current.systemVersion)
        アプリバージョン: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明")
        """
        
        composer.setMessageBody(deviceInfo, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}