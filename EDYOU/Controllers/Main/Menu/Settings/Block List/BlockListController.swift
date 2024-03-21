//
//  BlockListController.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

class BlockListController: BaseController {
    
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var cstTableViewBottom: NSLayoutConstraint!
    var adapter: BlockListAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = BlockListAdapter(tableView: tableView, textField: txtSearch )
        getBlockerUsers()
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstTableViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstTableViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }

}


// MARK: Actions
extension BlockListController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")
    }
}



extension BlockListController {
    func getBlockerUsers() {
       // self.startLoading(title: "")
        self.adapter.isLoading = true
        APIManager.social.getBlockUserlist { [weak self] friends, error in
            guard let self = self else { return }
            self.adapter.isLoading = false
            if error == nil {
                self.adapter.users = friends?.blockedusers == nil ? [] : (friends?.blockedusers)!
                self.adapter.searchedUsers = friends?.blockedusers == nil ? [] : (friends?.blockedusers)!
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoading = false
          //  self.stopLoading()
            self.tableView.reloadData()
        }
    }
}

// MARK: TextField Delegate
extension BlockListController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        btnClear.isHidden = expectedText.count == 0
        adapter.search(expectedText)
        
        
        
        
        return true
        
    }
}

