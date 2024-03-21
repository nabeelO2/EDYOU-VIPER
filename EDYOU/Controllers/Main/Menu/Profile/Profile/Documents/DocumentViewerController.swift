//
//  DocumentViewerController.swift
//  EDYOU
//
//  Created by Admin on 11/06/2022.
//

import UIKit
import PDFKit
import WebKit
class DocumentViewerController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    var url:String!
    var headerTitle: String!
    
    init(url:String, title: String) {
        self.url =  url
        self.headerTitle = title
        print(url)
        super.init(nibName: DocumentViewerController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    deinit {
        print("[DocumentViewerController] deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = self.headerTitle
        let uurl = URL(string: self.url)!
        if let data = try? Data(contentsOf: uurl), let _ = self.url.components(separatedBy: ".").last {
            lblError.isHidden = true
            let mimeType = uurl.mimeType()
            webView.load(data, mimeType: mimeType, characterEncodingName: "ut8", baseURL: uurl)
        } else {
            lblError.isHidden = false
            lblError.text = "Sorry, The file is not readable."
        }
    }
    
    
    
    @IBAction func didTapClose(_ sender: Any) {
        
        goBack()
    }
}
