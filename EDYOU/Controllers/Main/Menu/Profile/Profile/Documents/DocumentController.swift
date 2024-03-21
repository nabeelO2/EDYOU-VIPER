//
//  DocumentController.swift
//  EDYOU
//
//  Created by Admin on 07/06/2022.
//

import UIKit
import TransitionButton
import Foundation

class DocumentController: BaseController{
    
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var svDocumentStack: UIStackView!
    @IBOutlet weak var lblNoFilesSelected: UILabel!
    var fileUrl:URL!
    var uploadingIndex = 0
    var documentViews = [DocumentView]() {
        didSet {
            lblNoFilesSelected.isHidden = !documentViews.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoFilesSelected.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    init() {
        super.init(nibName: DocumentController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func didTapUpload(_ sender: Any) {
        
        DocumentPicker.shared.openPDF(from: self) { (url) in
            let document = Document(url: url)
            let documentView = DocumentView.instantiate(document: document, delegate: self)
            self.documentViews.append(documentView)
            self.svDocumentStack.addArrangedSubview(documentView)
        }
    }
    
    func onCompleteUploadingSingleDocument() {
        if self.uploadingIndex < self.documentViews.count {
            self.uploadDocument(selectedView: self.documentViews[uploadingIndex], onCompletion: onCompleteUploadingSingleDocument)
        } else {
            self.goBack()
        }
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        if !documentViews.isEmpty {
            btnSave.startAnimation()
            uploadDocument(selectedView: documentViews[uploadingIndex]) {
                self.onCompleteUploadingSingleDocument()
            }
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        goBack()
    }
}
extension DocumentController{
    func uploadDocument(selectedView: DocumentView, onCompletion: @escaping () -> Void){
        
        let document  = selectedView.document!
        let parameters: [String: Any] = [
            "document_title": document.name,
            "document_description": document.description,
        ]
        view.endEditing(true)
        var media = [Media]()
        if document.url.startAccessingSecurityScopedResource() {
            print("Access started")
        }
        if let data = try? Data(contentsOf: document.url) {
            media.append(Media(withData: data, key: "doc", mimeType: MimeType.pdf.rawValue, ext: document.fileType))
        } else {
            btnSave.stopAnimation()
            showErrorWith(message: "Cannot access content of document")
            return
        }
        document.url.stopAccessingSecurityScopedResource()
        let doc = media
        view.isUserInteractionEnabled = false
        selectedView.state = .uploading
        APIManager.fileUploader.addDocument(parameters: parameters, media: doc) { progress in
            selectedView.uploadingPercentage = Int(progress * 100)
        } completion: { response, error in
            self.view.isUserInteractionEnabled = true
            if error == nil {
                selectedView.state = .uploaded
                self.uploadingIndex += 1
                if self.uploadingIndex == self.documentViews.count {
                    self.btnSave.stopAnimation()
                }
                onCompletion()
            } else {
                self.btnSave.stopAnimation()
                selectedView.state = .pending
                selectedView.uploadingPercentage = 1
                self.showErrorWith(message: error!.message)
            }
        }
    }
}

/// Mark:- DocumentViewOutputDelegate
extension DocumentController: DocumentViewOutputDelegate {
    
    func didRemoveFile(document: Document, view: DocumentView) {
        documentViews.removeAll { docV in
            view == docV
        }
        view.removeFromSuperview()
    }
}
