//
//  FavEventsController.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//

import UIKit

class FavEventsController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    
    // MARK: - Properties
    var adapter: FavEventsAdapter!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = FavEventsAdapter(collectionView: collectionView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
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
extension FavEventsController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        txtSearch.becomeFirstResponder()
        viewSearch.showView()
    }
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        view.endEditing(true)
        viewSearch.hideView()
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")

    }
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")
    }
}


// MARK: TextField Delegate
extension FavEventsController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        btnClear.isHidden = expectedText.count == 0
        adapter.search(expectedText)
        return true
        
    }
}


// MARK: APIs
extension FavEventsController {
    func getFavorites() {
        APIManager.social.getFavorites(type: .events) { [weak self] favorites, error in
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            if error == nil {
                
//                let favoriteEvents = favorites?.events?.data?.events() ?? []
//                
//                self.adapter.events = favoriteEvents
//                if (self.txtSearch.text?.trimmed ?? "") == "" {
//                    self.adapter.searchedEvents = favoriteEvents
//                } else {
//                    self.adapter.search(self.txtSearch.text ?? "")
//                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.collectionView.reloadData()
        }
    }
}