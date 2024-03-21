//
//  WebViewController.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 14/03/2022.
//

import UIKit
import WebKit
import PDFKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var url: URL?
    var onDismiss: (() -> Void)?
    var onUrlChange: ((_ url: URL?) -> Void)?
    private var strTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        lblTitle.text = strTitle
        webView.isHidden = true
//        webView.navigationDelegate = self
//        webView.uiDelegate = self
//        if let url = self.url {
//            let request = URLRequest(url: url)
//            webView.load(request)
//            self.activityIndicator.isHidden = true
//        }
        DispatchQueue.global(qos: .background).async {
            if let document = PDFDocument(url: self.url!) {
                self.pdfView.document = document
            }
        }
        pdfView.autoScales = true
        
    }
    
    init(title: String, url: URL) {
        super.init(nibName: WebViewController.name, bundle: nil)
        self.strTitle = title
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension WebViewController: WKScriptMessageHandler ,  WKNavigationDelegate, WKUIDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // open in current view
        webView.load(navigationAction.request)
        
        // don't return a new view to build a popup into (the default behavior).
        return nil;
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust  else {
            completionHandler(.useCredential, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("didFinish")
        DispatchQueue.main.async {
            self.webView.scrollView.minimumZoomScale = 0.5
            self.webView.scrollView.maximumZoomScale = 10
            self.webView.scrollView.zoomScale = 1.32 * (webView.frame.width / 390)
            self.webView.scrollView.contentOffset.y = 104 * (webView.frame.width / 390)
            self.webView.alpha = 1
            self.activityIndicator.isHidden = true
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("didStartProvisionalNavigation")
        onUrlChange?(webView.url)
        self.activityIndicator.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        print("didFail: \(error.localizedDescription)")
        self.activityIndicator.isHidden = true
    }
}
