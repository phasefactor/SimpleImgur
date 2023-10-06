//
//  WebView.swift
//  SimpleImgur
//
//  Created by user on 10/3/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @State var navDel  = WebViewNavigationDelegate()
    
    
  //  var webView: WKWebView
    
    init() {
        let _ = print("INIT")
        
        
    }
    
    
    func makeUIView(context: Context) -> WKWebView {
        
        let _ = print("running makeUIView")
        
        let config  = WKWebViewConfiguration()
        let control = WKUserContentController()

        config.userContentController = control
        
        // Needed for the auto-play of video previews to not instantly enter full-screen.
        config.allowsInlineMediaPlayback = true
        
        // add block rules as described:
        // https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
        let jsonString = """
            [
                {
                    "trigger": {
                        "url-filter": ".*doubleclick\\\\.net.*"
                    },
                    "action":  {
                        "type": "block"
                    }
                },

                {
                    "trigger": {
                        "url-filter": ".*sentry-cdn\\\\.com.*"
                    },
                    "action":  {
                        "type": "block"
                    }
                },

                 {
                     "trigger": {
                         "url-filter": ".*smartadserver\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*assemblyexchange\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*amazon-adsystem\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*ccgateway\\\\.net.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*run\\\\.app.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*facebook\\\\.(net)?(com)?.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*scorecardresearch\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*google-analytics\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*sascdn\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*media-lab\\\\.ai.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*adsafeprotected\\\\.com.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*ad-delivery\\\\.net.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                 {
                     "trigger": {
                         "url-filter": ".*cloudfront\\\\.net.*"
                     },
                     "action":  {
                         "type": "block"
                     }
                 },

                {
                    "trigger": {
                        "url-filter": ".*"
                    },
                    "action": {
                        "type": "css-display-none",
                        "selector": "div.AdTop, div.BannerAd-cont, div.Ad-adhesive, a.get-app-block"
                    }
                }
            ]
        """
        
        // compile the rules list
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: jsonString) { (contentRuleList, error) in
                
            if error != nil {
                let _ = print("ERROR: creating rule list!!!\n ", error as Any)
                
                return
            }
            let _ = print("rule")
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
        
        let _ = print("running updateUIView")
        
        webView.load(request)
    }
    
    
    
    
    
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                if let host = url.host {
                    let _ = print("navigating to ", host)
                    
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
