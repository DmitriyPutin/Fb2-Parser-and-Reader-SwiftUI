//
//  WebView.swift
//  SferaInfo
//  View для отображения  Content
//  Created by Dmitriy Putin on 04.11.2021.
//

import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

struct WebView: UIViewRepresentable {

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var contensItem: TableOfContents

    @Binding var textHtml: String
    @Binding var nameContent: String
    
    var showAlert: ShowAlerts
    var chapterUid: Chapter
    
    /// Создание WKWebView
    func makeUIView(context: Context) -> WKWebView {
        
        let preferencesWK = WKPreferences()
        let configuration = WKWebViewConfiguration()
        
        configuration.preferences = preferencesWK
        for scriptItem in ScriptArray {
            configuration.userContentController.add(context.coordinator, contentWorld: .page, name: scriptItem.key)
        }
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        return webView
    }
    
    /// Обновление контента  WKWebView
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(textHtml, baseURL: Bundle.main.bundleURL)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        
        var webView: WebView
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init(_ webView: WebView) {
            self.webView = webView
        }
        
        deinit {
            webViewNavigationSubscriber?.cancel()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("didFinish")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.webViewNavigationSubscriber = self.webView.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
                switch navigation {
                case .backward:
                    webView.evaluateJavaScript("getForward(2)", completionHandler: nil)
                    webView.reload()
                case .forward:
                    webView.evaluateJavaScript("getForward(1)", completionHandler: nil)
                    webView.reload()
                case .search:
                    print(self.webView.contensItem.NameContent)
                    webView.evaluateJavaScript("getSearchItem('\(self.webView.contensItem.UID)')", completionHandler: nil)
                    webView.reload()
                case .exit:
                    webView.evaluateJavaScript("getCloseDocument('\(self.webView.nameContent)')", completionHandler: nil)
                    break
                case .getchapter:
                    webView.evaluateJavaScript("getChapter()", completionHandler: nil)
                    webView.reload()
                    break
                case .reload:
                    webView.reload()
                }
            })
            
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.webView.viewModel.isLoaderVisible.send(false)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            self.webView.viewModel.isLoaderVisible.send(true)
            //let scrollBook    = defaults.float(forKey: self.webView.post.id)
            //webView.evaluateJavaScript("getLoad('\(self.webView.post.NameContent)',\(scrollBook))", completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.webView.viewModel.isLoaderVisible.send(false)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            decisionHandler(.allow, preferences)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            print("didReceiveServerRedirectForProvisionalNavigation")
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            self.webView.viewModel.isLoaderVisible.send(false)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
            if message.name == "getLoad" {
                self.webView.viewModel.isLoaderVisible.send(false)
            }
            
            /// Вызов Alerta примечания
            if message.name == "setlinkContent" {
                guard let dict = message.body as? [String: AnyObject],
                      let keyLink    = dict["keyLink"]  as? String
                 else { return }
                
                self.webView.showAlert.displayAlert(keyNote: keyLink)
            }
            
            // Выделение текуще главы
            if message.name == "getChapter" {
                guard let dict = message.body as? [String: AnyObject],
                      let scrollchapter  = dict["scrollchapter"] as? Float,
                      let scroll         = dict["scroll"] as? Float,
                      let chapter        = dict["chapter"] as? String,
                      let count          = dict["count"] as? Float,
                      let itemId         = dict["itemId"] as? Float
                        
                else { return }
                
                self.webView.chapterUid.getCapter(scrollchapter: scrollchapter, scroll: scroll, chapterUid: chapter
                                , count: count, itemId: itemId)
             }
            
            // При закрытии книги
            if message.name == "getCloseDocument" {
                guard let dict = message.body as? [String: AnyObject],
                      let scroll  = dict["scroll"] as? Float,
                      let id      = dict["nameContent"]     as? String
                else { return }

                defaults.set(scroll, forKey: id)
            }
        }
    }
}

