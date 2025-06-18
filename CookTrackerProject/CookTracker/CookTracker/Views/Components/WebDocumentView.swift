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
        guard let path = Bundle.main.path(forResource: htmlFileName, ofType: "html", inDirectory: "Resources/Legal"),
              let htmlString = try? String(contentsOfFile: path, encoding: .utf8) else {
            // HTMLファイルが見つからない場合のフォールバック
            let errorHTML = """
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
                <p>ファイル名: \(htmlFileName).html</p>
                <p>設定画面からお問い合わせください。</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
            return
        }
        
        // ベースURLを設定してリソースの読み込みを可能にする
        let baseURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        webView.loadHTMLString(htmlString, baseURL: baseURL)
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
        guard let path = Bundle.main.path(forResource: htmlFileName, ofType: "html", inDirectory: "Resources/Legal"),
              let htmlString = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }
        
        let shareText = "\(title) - CookTracker\n\n\(htmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))"
        
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