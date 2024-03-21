//
//  TagGroup.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit
import PanModal

protocol TagGroupVCDelegate: AnyObject {
    func updateTaggedGroup(group: Group?)
}

class TagGroup: BaseController {
    // MARK: - Outlets
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var groups = [Group]()
    var searchedGroups = [Group]()
    weak var delegate: TagGroupVCDelegate?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.register(NewGroupCell.nib, forCellReuseIdentifier: NewGroupCell.identifier)
        groupTableView.delegate = self
        groupTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getGroups()
    }
    
    // MARK: - Fctions
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = groups.filter { $0.groupName?.lowercased().contains(t) == true }
            self.searchedGroups = f
        } else {
            self.searchedGroups = groups
        }
        
        groupTableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.updateTaggedGroup(group: nil)
        
        if (navigationController?.presentationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension TagGroup : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchedGroups = self.groups
        self.groupTableView.reloadData()
    }
}

// MARK: - TableView delegate and datasource
extension TagGroup : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
        
        cell.setData(searchedGroups[indexPath.row], forCreatePost: true)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (navigationController?.presentationController != nil) {
            delegate?.updateTaggedGroup(group: searchedGroups[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.updateTaggedGroup(group: searchedGroups[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TagGroup {
    func getGroups() {
        APIManager.social.getGroups { [weak self] my, joined, invited, pending, error in
            guard let self = self else { return }
            
            if error == nil {
                self.groups = my + joined
                self.searchedGroups = my + joined
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            self.groupTableView.reloadData()
        }
    }
}

extension TagGroup: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return groupTableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(self.view.frame.height - 50)
    }
}
