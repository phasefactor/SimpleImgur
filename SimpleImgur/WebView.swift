//
//  WebView.swift
//  SimpleImgur
//
//  Created by user on 10/3/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let navDel  = WebViewNavigationDelegate()
    
    func makeUIView(context: Context) -> WKWebView {
        let config  = WKWebViewConfiguration()
        let control = WKUserContentController()

        config.userContentController = control
        
        // Needed for videos to not instantly enter full-screen.
        config.allowsInlineMediaPlayback = true
        
        
        // inject a short bit of JS to try to upgrade the size and resolution of webp images being saved.
        
        // might need to be tweaked...
        let source = """
        // load high res version of images that might be saved/copied
        document.body.addEventListener('touchstart', (event) => {
            if (event.target.tagName == "IMG" &&
                event.target.src.includes(".webp")) {
                
                let url = new URLSearchParams(event.target.src.split('?')[1]);
                url.set("fidelity", "grand");
                url.set("maxwidth", "9999");
                
                event.target.src = event.target.src.split('?')[0] + "?" + url.toString();
            }
        });
        """
        
        let script = WKUserScript(source: source,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: true)
        
        control.addUserScript(script)
        
        
        // add block rules as described:
        // https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
        
        // list of domains that imgur loads nonsense from
        let urlList = ["sentry-cdn.com", "ccgateway.net", "google-analytics.com", "fundingchoicesmessages.google.com", "btloader.com", "ad-delivery.net", "media-lab.ai", "sascdn.com", "scorecardresearch.com", "stretchsquirrel.com", "doubleclick.net", "exelator.com", "googlesyndication.com", "facebook.(net)?(com)?", "cloudfront.net", "t.imgur.com"]
        
        // , "smartadserver.com", "assemblyexchange.com", "amazon-adsystem.com", "run.app",  "adsafeprotected.com", "merequartz.com"
        
        // build our JSON block list from scratch
        var jsonString = "["
        
        for url in urlList {
            jsonString += "{\"trigger\":{\"url-filter\":\".*\(url.replacingOccurrences(of: ".", with: "\\\\.")).*\"},\"action\":{\"type\":\"block\"}},"
        }
        
        // css rule to hide any empty ads
        jsonString += "{\"trigger\":{\"url-filter\":\".*\"},\"action\":{\"type\":\"css-display-none\",\"selector\":\"div:has(>div.fast-grid-ad)\"}}"
        
        
        
        jsonString += "]"
        
        
        // compile the rules list
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: jsonString) { (contentRuleList, error) in
                
            if error != nil {
                let _ = print("ERROR: creating rule list!!!\n ", error as Any)
                
                return
            }
            
            // attach compiled rules to config
            config.userContentController.add(contentRuleList!)
        }
        
        // make the webView
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // Assign the NavigationDelegate
        webView.navigationDelegate = navDel
        
        // Allow Safari developer tools to connect to the app for debugging
        webView.isInspectable = true
        
        // disable scrolling to top when the top of the screen (above the safe area) is touched
        webView.scrollView.scrollsToTop = false
        
        return webView
    }
    
    
    
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: URL(string: "https://imgur.com")!)
        
        webView.load(request)
    }
    
    
    
    
    
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                if let host = url.host {
                    if host.contains("imgur.com") || host.contains("imgur.io") {
                            decisionHandler(.allow)
                            return
                    }
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
