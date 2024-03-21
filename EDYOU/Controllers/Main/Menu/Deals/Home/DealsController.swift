//
//  DealsController.swift
//  EDYOU
//
//  Created by  Mac on 22/10/2021.
//

import UIKit

class DealsController: BaseController {
    
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    
    var adapter: DealsAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = DealsAdapter(collectionView: collectionView)
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstCollectionViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstCollectionViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }

}


// MARK: Actions
extension DealsController {
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        viewSearch.showView()
    }
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        txtSearch.text = ""
        viewSearch.hideView()
//        adapter.search("")
    }
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
//        adapter.search("")
    }
}



// MARK: TextField Delegate
extension DealsController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        btnClear.isHidden = expectedText.count == 0
        print(expectedText)
//        adapter.search(expectedText)
        return true
        
    }
}
