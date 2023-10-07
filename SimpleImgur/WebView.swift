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
        
        
        // inject a short bit of JS to fix the logo.  seems that they are purposefully
        // blocking the click from actually causing the link to navigate...
        // using timeout because the imgur ui is built dynamically on page load
        let source = """
        setTimeout(() => {
            let el = document.querySelector("a.Navbar-logo");
            el.parentNode.replaceChild(el.cloneNode(true), el);
        }, 5000);
        """
        
        let script = WKUserScript(source: source,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: true)
        
        control.addUserScript(script)
        
        
        // add block rules as described:
        // https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
        
        // list of domains that imgur loads nonsense from
        let urlList = ["doubleclick.net", "sentry-cdn.com", "smartadserver.com", "assemblyexchange.com", "amazon-adsystem.com", "ccgateway.net", "run.app", "facebook.(net)?(com)?", "scorecardresearch.com", "google-analytics.com", "sascdn.com", "media-lab.ai", "adsafeprotected.com", "ad-delivery.net", "cloudfront.net", "stretchsquirrel.com", "merequartz.com", "btloader.com"]
        
        // build our JSON block list from scratch
        var jsonString = "["
        
        for url in urlList {
            // running split twice is gross, but the list of urls is very short
            jsonString += "{\"trigger\":{\"url-filter\":\".*\(url.split(separator:".")[0])\\\\.\(url.split(separator:".")[1]).*\"},\"action\":{\"type\":\"block\"}},"
        }
        
        // css rule to hide any empty ad spots and the Get App button
        jsonString += "{\"trigger\":{\"url-filter\":\".*\"},\"action\":{\"type\":\"css-display-none\",\"selector\":\"div.AdTop,div.BannerAd-cont,div.Ad-adhesive,a.get-app-block\"}}"
        
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
        
        return webView
    }
    
    
    
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: URL(string: "https://imgur.io")!)
        
        webView.load(request)
    }
    
    
    
    
    
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                if let host = url.host {
                    if host.contains("imgur.com") || host.contains("imgur.io") {
                            decisionHandler(.allow)
                            return
                    } else {
                        // kludge to fix a weird redirect
                        if !(host.hasPrefix("about:") || host.contains("googlesyndication.com") ){
                            // open external links in default browser
                            UIApplication.shared.open(url)
                            // then fall through to the .cancel
                        }
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
