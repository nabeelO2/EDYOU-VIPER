//
//  SearchController.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import UIKit

class SearchController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var cstStackViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var cstTableViewBottom: NSLayoutConstraint!
    var users = [User]()
    
    // MARK: - Properties
    var adapter: SearchAdapter!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = SearchAdapter(tableView: tableView)
        getAllUsers()
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstTableViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom - (txtSearch.keyboardToolbar.height)
        } else {
            cstTableViewBottom.constant = 0
        }
    }

}

// MARK: - Actions
extension SearchController {
    
    @IBAction func didTapClearButton(_ sender: Any) {
        view.endEditing(true)
        txtSearch.text = ""
        btnClear.isHidden = true
        cstStackViewTrailing.constant = 20
        view.layoutIfNeeded(true)
        search("")
    }
}
// MARK: - Utility Methods
extension SearchController {
    func search(_ text: String) {
        let t = text.lowercased().trimmed
        
        if t.count > 0 {
            let filtered = users.filter {
                $0.name?.completeName.lowercased().contains(t) == true
            }
            adapter.users = filtered
        } else {
            adapter.users = []
        }
        tableView.reloadData()
        
    }
}


// MARK: - TextField Delegate
extension SearchController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        btnClear.isHidden = false
        cstStackViewTrailing.constant = 0
        view.layoutIfNeeded(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.trimmed ?? "") == "" {
            textField.text = ""
            btnClear.isHidden = true
            cstStackViewTrailing.constant = 20
            view.layoutIfNeeded(true)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        search(expectedText)
        
        return true
        
    }
}

// MARK: - Web APIs
extension SearchController {
    func getAllUsers() {
        APIManager.social.getAllUsers { [weak self] users, error in
            guard let self = self else { return }
            
            if error == nil {
                self.users = users
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
    }
}
