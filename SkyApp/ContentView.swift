import SwiftUI
import WebKit
import UIKit

struct ContentView: View {
    @State private var canGoBack = false
    @State private var isLoading = true
    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                // 返回按钮
                Button(action: {
                    NotificationCenter.default.post(name: .webGoBack, object: nil)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(canGoBack ? .blue : .gray)
                        .frame(width: 44, height: 44)
                }
                .disabled(!canGoBack)

                Spacer()

                // 标题
                Text("Sky光遇云端")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // 清缓存按钮
                Button(action: {
                    showClearConfirm = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 8)
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)

            // WebView
            WebView(canGoBack: $canGoBack)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            // 每次打开 App 清除缓存
            WebCache.clearAllCache()
        }
        .alert("清除缓存", isPresented: $showClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("确认清除", role: .destructive) {
                WebCache.clearAllCache()
                NotificationCenter.default.post(name: .webReload, object: nil)
            }
        } message: {
            Text("将清除网页缓存和 Cookie，并刷新页面。")
        }
    }
}

// WebView 协调器，用于监听导航状态
struct WebView: UIViewRepresentable {
    @Binding var canGoBack: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = .white

        // 监听返回和刷新通知
        NotificationCenter.default.addObserver(
            forName: .webGoBack,
            object: nil,
            queue: .main
        ) { _ in
            if webView.canGoBack {
                webView.goBack()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .webReload,
            object: nil,
            queue: .main
        ) { _ in
            webView.reload()
        }

        // 加载目标网址
        if let url = URL(string: "http://120.48.161.149:5000/") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 更新返回按钮状态
        context.coordinator.updateCanGoBack()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func updateCanGoBack() {
            // 通过通知更新返回按钮状态
        }

        // 处理 target="_blank" 和 window.open() 新窗口
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            // 在新窗口打开链接时，改用当前 WebView 加载
            if navigationAction.targetFrame == nil,
               let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        // 处理 JS alert
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                completionHandler()
            })
            if let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                root.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }

        // 处理 JS confirm
        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            let alert = UIAlertController(title: "确认", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                completionHandler(true)
            })
            if let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                root.present(alert, animated: true)
            } else {
                completionHandler(false)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
            }
        }
    }
}

// 缓存清理工具
struct WebCache {
    static func clearAllCache() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) { }
        }
    }
}

// 通知名称
extension Notification.Name {
    static let webGoBack = Notification.Name("webGoBack")
    static let webReload = Notification.Name("webReload")
}