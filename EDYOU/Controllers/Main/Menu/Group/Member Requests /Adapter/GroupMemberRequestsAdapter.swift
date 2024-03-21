//
//  
//  GroupMembersAdapter.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//
//

import UIKit
import TransitionButton

class GroupMemberRequestsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    weak var collectionView: UICollectionView!
    
    var parent: GroupMemberRequestsController? {
        return tableView.viewContainingController() as? GroupMemberRequestsController
    }
    var group: GroupAdminData
    var groupMemberCategories = ["Received", "Sent"]
    var receivedCount = Int()
    var sentCount = Int()
    
    // MARK: - Initializers
    init(tableView: UITableView, group: GroupAdminData,collectionView: UICollectionView) {
        self.group = group
        super.init()
        
        self.tableView = tableView
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        tableView.register(MemberRequestCell.nib, forCellReuseIdentifier: MemberRequestCell.identifier)
        tableView.register(MembersSentTableViewCell.nib, forCellReuseIdentifier: MembersSentTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.register(EventsSubNavBarCellItem.nib, forCellWithReuseIdentifier: EventsSubNavBarCellItem.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.parent?.selectedTab = .received
    }
    
}


// MARK: - Utility Methods
extension GroupMemberRequestsAdapter {
    @objc func didTapApproveButton(_ sender: TransitionButton) {
        self.updateRequest(sender: sender, action: .acceptMemberRequest)
    }
    @objc func didTapDeclineButton(_ sender: TransitionButton) {
        self.updateRequest(sender: sender, action: .rejectMemberRequest)
    }
    
    private func updateRequest(sender: TransitionButton, action : GroupAdminAction) {
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
        guard let u = group.pending?.object(at: sender.tag) else { return }
        sender.startAnimation()
        cell?.isUserInteractionEnabled = false
        update(user: u, action: action) { [weak self] status in
            cell?.isUserInteractionEnabled = true
            sender.stopAnimation(revertAfterDelay: 0.2)
            if status {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self?.group.pending?.remove(at: sender.tag)
                    self?.tableView.reloadData()
                    self?.collectionView.reloadData()
                    self?.refreshRequests()
                }
            }
        }
    }
}


// MARK: - TableView DataSource and Delegates
extension GroupMemberRequestsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        receivedCount = group.pending?.count ?? 0
        sentCount = group.sent?.count ?? 0
        if parent?.selectedTab == .received {
            return receivedCount
        } else {
            return sentCount
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if parent?.selectedTab == .received {
            return 104
        } else {
            return 55
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if parent?.selectedTab == .received{
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberRequestCell.identifier, for: indexPath) as! MemberRequestCell
            
            if let member = group.pending?.object(at: indexPath.row) {
                cell.setData(member)
            }
            
            cell.isUserInteractionEnabled = true
            cell.btnApprove.tag = indexPath.row
            cell.btnDecline.tag = indexPath.row
            cell.btnApprove.addTarget(self, action: #selector(didTapApproveButton(_:)), for: .touchUpInside)
            cell.btnDecline.addTarget(self, action: #selector(didTapDeclineButton(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MembersSentTableViewCell.identifier, for: indexPath) as! MembersSentTableViewCell
            
            if let member = group.sent?.object(at: indexPath.row) {
                cell.setData(member)
            }
            cell.isUserInteractionEnabled = true
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if parent?.selectedTab == .received {
            if let user = group.pending?.object(at: indexPath.row) {
                let controller = ProfileController(user: user)
                let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                navC?.pushViewController(controller, animated: true)
                
            }
        } else {
            if let user = group.sent?.object(at: indexPath.row) {
                let controller = ProfileController(user: user)
                let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                navC?.pushViewController(controller, animated: true)
                
            }
        }
    }
}
// MARK: - CollectionView DataSource and Delegates
extension GroupMemberRequestsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupMemberCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemName = UILabel(frame: CGRect.zero)
        if indexPath.row == 0 {
            itemName.text = "\(groupMemberCategories[indexPath.row]) (\(receivedCount))"
        } else {
            //pending count need to be updated
            itemName.text = "\(groupMemberCategories[indexPath.row]) (\(sentCount))"
        }
        itemName.sizeToFit()
        var width: CGFloat = 0
        width = itemName.frame.width + 20
        
        return CGSize(width: width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsSubNavBarCellItem.identifier, for: indexPath) as! EventsSubNavBarCellItem
        let row = indexPath.row
        cell.containerView.backgroundColor = UIColor(hexString: "F3F5F8")
        if (parent?.selectedTab == .received  && row == 0) {
            cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
        } else if (parent?.selectedTab == .sent && row == 1) {
            cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
        }
        if row == 0 {
            cell.design(showWithIcons: false, text: "\(groupMemberCategories[row]) (\(receivedCount))")
        } else if row == 1{
            cell.design(showWithIcons: false, text: "\(groupMemberCategories[row]) (\(sentCount))")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if (row == 0) {
            // open filters
            parent?.selectedTab = .received
        } else if (row == 1) {
            parent?.selectedTab = .sent
        }
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
}

extension GroupMemberRequestsAdapter {
    func update(user: User, action: GroupAdminAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let gId = group.groupID else { return }
        
        APIManager.social.groupAdminAction(groupId: gId, userId: user.userID!, action: action) { error in
            if error == nil {
                completion(true)
            } else {
                self.parent?.showErrorWith(message: error!.message)
                completion(false)
            }
        }
    }
    private func refreshRequests() {
        self.parent?.getData()
    }
}
enum GroupMembersHeaderType: Int {
    case received, sent
}
