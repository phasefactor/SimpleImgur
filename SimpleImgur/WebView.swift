//
//  WebView.swift
//  SimpleImgur
//
//  Created by user on 10/3/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // defined below
    @State var navDel = WebViewNavigationDelegate()
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        
        // Needed for the auto-play of video previews to not instantly enter full-screen.
        webConfiguration.allowsInlineMediaPlayback = true
        
        // Setup a content controller so that we can inject JS to the WKWebView
        let contentController = WKUserContentController()
        
        // load JS from files
        var source = "console.log('failed to load script.js');"
        do {
            source = try String(contentsOf: Bundle.main.url(forResource: "atDocumentStartScript", withExtension: "js")!)
        } catch {}
  
        var script = WKUserScript(source: source,
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        
        contentController.addUserScript(script)
        
        // load JS from files
        source = "console.log('failed to load script.js');"
        do {
            source = try String(contentsOf: Bundle.main.url(forResource: "atDocumentEndScript", withExtension: "js")!)
        } catch {}
  
        script = WKUserScript(source: source,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: true)
        
        contentController.addUserScript(script)
        
        // Attach the content controller to the configuration
        webConfiguration.userContentController = contentController
        
        //
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        // Assign the NavigationDelegate
        webView.navigationDelegate = navDel
        
        
        webView.allowsBackForwardNavigationGestures = true
        
        // Allow Safari developer tools to connect to the app for debugging
        webView.isInspectable = true
        
        return webView
    }
    
    
    
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: URL(string: "https://imgur.com")!)
        
        webView.load(request)
        
        
        
        webView.allowsBackForwardNavigationGestures = true
    }
    
    
    
    
    
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                    if ((url.host?.contains("imgur.com")) != nil) {
                        decisionHandler(.allow)
                        return
                    } else {
                        // open external links in default browser
                        UIApplication.shared.open(url)
                        // then fall through to the .cancel
                    }
                }
                
                decisionHandler(.cancel)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            
             decisionHandler(.allow)
        }
    }
}




#Preview {
    WebView()
}
