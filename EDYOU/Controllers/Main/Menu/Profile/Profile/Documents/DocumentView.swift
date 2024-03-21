//
//  DocumentView.swift
//  EDYOU
//
//  Created by Masroor on 16/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class DocumentView: UIView {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var progressView: KDCircularProgress!
    var output: DocumentViewOutputDelegate!
    var document: Document!
    var uploadingPercentage: Int = 1 {
        didSet {
//            self.state = .create(percentage: uploadingPercentage)
            btnClose.setTitle("\(uploadingPercentage)%", for: .normal)
            self.progressView.progress = Double(uploadingPercentage)/100 //because progress is from 0-1
        }
    }
    var state = DocumentViewState.pending {
        didSet {
            btnClose.isUserInteractionEnabled = state == .pending
            if(state == .pending){
                btnClose.setImage(UIImage(named: "ic_cross"), for: .normal)
                btnClose.setTitle(nil, for: .normal)
            } else if state == .uploaded{
                btnClose.setImage(UIImage(named: "ic_tick"), for: .normal)
                btnClose.setTitle(nil, for: .normal)
            } else {
                btnClose.setImage(nil, for: .normal)
            }
        }
    }
    
    static func instantiate(document: Document, delegate: DocumentViewOutputDelegate) -> DocumentView {
        let view =  UINib(
            nibName: String(describing: Self.self),
            bundle: .main
        ).instantiate(withOwner: nil, options: nil)[0] as! DocumentView
        view.lblName.text = document.name
        view.lblDescription.text = document.description
        view.document = document
        view.output = delegate
        view.uploadingPercentage = 1
        view.state = .pending
        return view
    }
    
    @IBAction func actDidRemoveFile(_ sender: UIButton) {
        self.output.didRemoveFile(document: document, view: self)
    }
}
