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

// MARK: - Legal Document View
struct LegalDocumentView: View {
    let title: String
    let htmlFileName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let htmlContent = loadHTMLContent() {
                        Text(htmlContent)
                            .font(.body)
                            .padding()
                    } else {
                        Text("ドキュメントを読み込めませんでした。")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func loadHTMLContent() -> String? {
        // 実際の実装では HTML ファイルを読み込み
        // 今はプレースホルダーテキストを返す
        switch htmlFileName {
        case "terms_of_service":
            return """
            利用規約
            
            第1条（適用）
            本規約は、CookTrackerアプリ（以下「本アプリ」）の利用条件を定めるものです。
            
            第2条（利用登録）
            本アプリの利用は無料です。アカウント登録は任意です。
            
            第3条（禁止事項）
            ユーザーは以下の行為を行ってはなりません：
            ・本アプリの不正利用
            ・他のユーザーへの迷惑行為
            ・法令に違反する行為
            
            第4条（免責事項）
            本アプリの利用によって生じた損害について、当社は一切の責任を負いません。
            
            第5条（規約の変更）
            当社は必要に応じて本規約を変更することがあります。
            
            制定日：2025年6月18日
            """
            
        case "privacy_policy":
            return """
            プライバシーポリシー
            
            個人情報の取り扱いについて
            
            1. 収集する情報
            本アプリでは以下の情報を収集する場合があります：
            ・レシピ情報
            ・調理記録
            ・アプリ利用状況
            
            2. 情報の利用目的
            収集した情報は以下の目的で利用します：
            ・サービスの提供・改善
            ・ユーザーサポート
            
            3. 情報の第三者提供
            個人情報を第三者に提供することはありません。
            
            4. データの保存
            データはデバイス内にローカル保存されます。
            
            5. お問い合わせ
            プライバシーに関するお問い合わせは設定画面からご連絡ください。
            
            制定日：2025年6月18日
            最終更新日：2025年6月18日
            """
            
        default:
            return nil
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