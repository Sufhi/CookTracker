//
//  WebDocumentView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI
import WebKit

/// HTMLドキュメントを表示するWebビューコンポーネント
/// - 法的文書（利用規約・プライバシーポリシー）の表示に使用
struct WebDocumentView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // HTMLファイルを読み込み
        loadHTMLFile(in: webView)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 更新時には何もしない
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func loadHTMLFile(in webView: WKWebView) {
        let htmlString = getHTMLContent(for: htmlFileName)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func getHTMLContent(for fileName: String) -> String {
        switch fileName {
        case "terms_of_service":
            return getTermsOfServiceHTML()
        case "privacy_policy":
            return getPrivacyPolicyHTML()
        default:
            return getErrorHTML(fileName: fileName)
        }
    }
    
    private func getErrorHTML(fileName: String) -> String {
        return """
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    padding: 20px;
                    text-align: center;
                    color: #666;
                }
            </style>
        </head>
        <body>
            <h2>ドキュメントを読み込めませんでした</h2>
            <p>ファイル名: \(fileName).html</p>
            <p>設定画面からお問い合わせください。</p>
        </body>
        </html>
        """
    }
    
    private func getTermsOfServiceHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="ja">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>利用規約 - CookTracker</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    background-color: #f9f9f9;
                }
                .container {
                    background-color: white;
                    padding: 30px;
                    border-radius: 12px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                h1 {
                    color: #8B4513;
                    text-align: center;
                    margin-bottom: 30px;
                    font-size: 28px;
                }
                h2 {
                    color: #8B4513;
                    margin-top: 30px;
                    margin-bottom: 15px;
                    font-size: 20px;
                }
                p {
                    margin-bottom: 15px;
                }
                .last-updated {
                    text-align: center;
                    color: #666;
                    font-size: 14px;
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 1px solid #eee;
                }
                .highlight {
                    background-color: #FFF8DC;
                    padding: 15px;
                    border-left: 4px solid #8B4513;
                    margin: 20px 0;
                }
                ul {
                    padding-left: 20px;
                }
                li {
                    margin-bottom: 8px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>CookTracker 利用規約</h1>
                
                <div class="highlight">
                    <p><strong>重要：</strong>本アプリをご利用いただく前に、以下の利用規約をよくお読みください。本アプリを使用することで、本規約に同意したものとみなされます。</p>
                </div>

                <h2>第1条（適用）</h2>
                <p>本規約は、CookTracker開発者（以下「開発者」）が提供するCookTrackerアプリケーション（以下「本アプリ」）の利用条件を定めるものです。ユーザーの皆様（以下「ユーザー」）には、本規約に従って本アプリをご利用いただきます。</p>

                <h2>第2条（利用登録）</h2>
                <p>本アプリの基本機能は無料でご利用いただけます。アカウント登録は任意であり、登録なしでも全ての機能をご利用いただけます。</p>
                <p>アカウント登録を行う場合は、正確な情報を提供し、常に最新の状態に保つことをお約束ください。</p>

                <h2>第3条（禁止事項）</h2>
                <p>ユーザーは、本アプリの利用にあたり、以下の行為を行ってはなりません：</p>
                <ul>
                    <li>法令または公序良俗に反する行為</li>
                    <li>本アプリの運営を妨害する行為</li>
                    <li>他のユーザーまたは第三者に迷惑をかける行為</li>
                    <li>本アプリの機能を不正に利用する行為</li>
                    <li>開発者の知的財産権を侵害する行為</li>
                    <li>コンピューターウイルス等の有害なプログラムを送信する行為</li>
                    <li>その他、開発者が不適切と判断する行為</li>
                </ul>

                <h2>第4条（知的財産権）</h2>
                <p>本アプリに関する知的財産権は全て開発者に帰属します。ユーザーは、本アプリを利用する権利のみを有し、所有権を取得するものではありません。</p>
                <p>ユーザーが本アプリに投稿したコンテンツの著作権は、ユーザーに帰属します。</p>

                <h2>第5条（プライバシー）</h2>
                <p>開発者は、ユーザーのプライバシーを尊重し、個人情報の取り扱いについては別途定めるプライバシーポリシーに従います。</p>

                <h2>第6条（免責事項）</h2>
                <p>開発者は、以下の事項について一切の責任を負いません：</p>
                <ul>
                    <li>本アプリの利用によってユーザーに生じた損害</li>
                    <li>本アプリのサービス中断、データの消失等</li>
                    <li>ユーザー間でのトラブル</li>
                    <li>第三者によるサービスの利用</li>
                </ul>
                <p>本アプリは「現状有姿」で提供され、開発者は本アプリの完全性、正確性、確実性について保証しません。</p>

                <h2>第7条（サービスの変更・終了）</h2>
                <p>開発者は、ユーザーに事前に通知することなく、本アプリの内容を変更し、または本アプリの提供を終了することができます。これらによってユーザーに生じた損害について、開発者は一切の責任を負いません。</p>

                <h2>第8条（規約の変更）</h2>
                <p>開発者は、必要と判断した場合には、本規約を変更することがあります。変更後の規約は、本アプリ内またはApp Storeで公表した時点から効力を生じます。</p>

                <h2>第9条（準拠法・裁判管轄）</h2>
                <p>本規約の解釈にあたっては、日本法を準拠法とします。本アプリに関して紛争が生じた場合には、東京地方裁判所を専属的合意管轄とします。</p>

                <h2>第10条（お問い合わせ）</h2>
                <p>本規約に関するお問い合わせは、アプリ内の設定画面からお問い合わせください。</p>

                <div class="last-updated">
                    <p>制定日：2025年6月18日<br>
                    最終更新日：2025年6月27日<br>
                    CookTracker開発者</p>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    private func getPrivacyPolicyHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="ja">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>プライバシーポリシー - CookTracker</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    background-color: #f9f9f9;
                }
                .container {
                    background-color: white;
                    padding: 30px;
                    border-radius: 12px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                h1 {
                    color: #8B4513;
                    text-align: center;
                    margin-bottom: 30px;
                    font-size: 28px;
                }
                h2 {
                    color: #8B4513;
                    margin-top: 30px;
                    margin-bottom: 15px;
                    font-size: 20px;
                }
                p {
                    margin-bottom: 15px;
                }
                .last-updated {
                    text-align: center;
                    color: #666;
                    font-size: 14px;
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 1px solid #eee;
                }
                .highlight {
                    background-color: #FFF8DC;
                    padding: 15px;
                    border-left: 4px solid #8B4513;
                    margin: 20px 0;
                }
                ul {
                    padding-left: 20px;
                }
                li {
                    margin-bottom: 8px;
                }
                .data-table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: 20px 0;
                }
                .data-table th, .data-table td {
                    border: 1px solid #ddd;
                    padding: 12px;
                    text-align: left;
                }
                .data-table th {
                    background-color: #f5f5f5;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>CookTracker プライバシーポリシー</h1>
                
                <div class="highlight">
                    <p><strong>お客様のプライバシーを保護することは、開発者にとって非常に重要です。</strong>本ポリシーでは、CookTrackerアプリにおける個人情報の取り扱いについて詳しく説明します。</p>
                </div>

                <h2>1. 基本方針</h2>
                <p>CookTracker開発者（以下「開発者」）は、お客様の個人情報の保護に関して、以下の基本方針に基づいて取り組んでいます：</p>
                <ul>
                    <li>個人情報の収集は必要最小限に留める</li>
                    <li>収集した情報は明確な目的のためにのみ使用する</li>
                    <li>お客様の同意なしに第三者に提供しない</li>
                    <li>適切なセキュリティ対策を実施する</li>
                </ul>

                <h2>2. 収集する情報</h2>
                <p>CookTrackerアプリでは、以下の情報を収集する場合があります：</p>
                
                <table class="data-table">
                    <tr>
                        <th>情報の種類</th>
                        <th>収集方法</th>
                        <th>収集目的</th>
                    </tr>
                    <tr>
                        <td>レシピ情報</td>
                        <td>ユーザー入力</td>
                        <td>アプリ機能の提供</td>
                    </tr>
                    <tr>
                        <td>調理記録</td>
                        <td>ユーザー入力・タイマー使用</td>
                        <td>調理履歴の管理・統計表示</td>
                    </tr>
                    <tr>
                        <td>写真データ</td>
                        <td>カメラ・フォトライブラリ</td>
                        <td>調理記録への添付</td>
                    </tr>
                    <tr>
                        <td>アプリ利用状況</td>
                        <td>自動収集</td>
                        <td>サービス改善・不具合修正</td>
                    </tr>
                    <tr>
                        <td>デバイス情報</td>
                        <td>自動収集</td>
                        <td>技術サポート・互換性確保</td>
                    </tr>
                </table>

                <h2>3. 情報の利用目的</h2>
                <p>収集した個人情報は、以下の目的でのみ利用いたします：</p>
                <ul>
                    <li>CookTrackerアプリのサービス提供</li>
                    <li>ユーザーサポート・技術サポート</li>
                    <li>サービスの改善・新機能開発</li>
                    <li>不具合の調査・修正</li>
                    <li>統計データの作成（個人を特定できない形式）</li>
                </ul>

                <h2>4. データの保存・管理</h2>
                <p><strong>ローカル保存：</strong>お客様のレシピ情報、調理記録、写真等は、お客様のデバイス内にローカル保存されます。これらのデータは開発者のサーバーに送信されることはありません。</p>
                <p><strong>セキュリティ：</strong>お客様のデータは、iOSの標準的なセキュリティ機能により保護されています。</p>
                <p><strong>バックアップ：</strong>データのバックアップはiCloudを通じて行われる場合があります。これはAppleのプライバシーポリシーに従って管理されます。</p>

                <h2>5. 第三者への情報提供</h2>
                <p>開発者は、以下の場合を除き、お客様の個人情報を第三者に提供することはありません：</p>
                <ul>
                    <li>お客様の同意がある場合</li>
                    <li>法令に基づく場合</li>
                    <li>人の生命、身体または財産の保護のために必要がある場合</li>
                    <li>公衆衛生の向上または児童の健全な育成の推進のために特に必要がある場合</li>
                </ul>

                <h2>6. アクセス権限</h2>
                <p>CookTrackerアプリが要求するアクセス権限とその目的：</p>
                <ul>
                    <li><strong>カメラ：</strong>調理完了時の写真撮影のため</li>
                    <li><strong>フォトライブラリ：</strong>既存の写真を調理記録に添付するため</li>
                    <li><strong>通知：</strong>タイマー完了時の通知送信のため</li>
                </ul>
                <p>これらの権限は必要に応じてのみ使用され、他の目的で使用されることはありません。</p>

                <h2>7. お客様の権利</h2>
                <p>お客様は、ご自身の個人情報について以下の権利を有します：</p>
                <ul>
                    <li>データの閲覧・確認</li>
                    <li>データの修正・削除</li>
                    <li>アプリの削除による全データの消去</li>
                </ul>
                <p>アプリをデバイスから削除することで、保存されている全ての個人データが削除されます。</p>

                <h2>8. 子どもの個人情報</h2>
                <p>開発者は、13歳未満の子どもから意図的に個人情報を収集することはありません。13歳未満の子どもが個人情報を提供したことを知った場合、速やかにその情報を削除いたします。</p>

                <h2>9. プライバシーポリシーの変更</h2>
                <p>開発者は、法令の変更やサービス内容の変更に伴い、本ポリシーを変更することがあります。変更は、アプリ内での通知またはApp Storeでの公表により効力を生じます。</p>

                <h2>10. お問い合わせ</h2>
                <p>本プライバシーポリシーに関するご質問、ご意見、苦情等がございましたら、アプリ内の設定画面からお問い合わせください。</p>
                <p>適切かつ迅速に対応させていただきます。</p>

                <div class="last-updated">
                    <p>制定日：2025年6月18日<br>
                    最終更新日：2025年6月27日<br>
                    CookTracker開発者</p>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 外部リンクをSafariで開く
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

// MARK: - Enhanced Legal Document View
struct LegalDocumentView: View {
    let title: String
    let htmlFileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // WebView
                WebDocumentView(htmlFileName: htmlFileName)
                    .onAppear {
                        // ローディング状態を少し遅らせて解除（WebViewの読み込み時間を考慮）
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLoading = false
                        }
                    }
                
                // ローディングインジケーター
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("読み込み中...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            shareDocument()
                        }) {
                            Label("共有", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    private func shareDocument() {
        // WebDocumentViewのgetHTMLContentメソッドを利用
        let webDocumentView = WebDocumentView(htmlFileName: htmlFileName)
        let htmlString = webDocumentView.getHTMLContent(for: htmlFileName)
        let shareText = "\(title) - CookTracker\n\n\(htmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview
struct WebDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        LegalDocumentView(
            title: "利用規約",
            htmlFileName: "terms_of_service"
        )
    }
}