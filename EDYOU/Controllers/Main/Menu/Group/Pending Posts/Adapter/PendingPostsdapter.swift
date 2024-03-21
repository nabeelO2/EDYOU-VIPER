//
//  
//  PendingPostsdapter.swift
//  EDYOU
//
//  Created by  Mac on 17/10/2021.
//
//

import UIKit
import TransitionButton

class PendingPostsdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var parent: PendingPostsController? {
        return tableView.viewContainingController() as? PendingPostsController
    }
    var stories = [Story]()
    var totalRecord: Int = -1
    var isLoading = true
    var group: GroupAdminData
    
    
    // MARK: - Initializers
    init(tableView: UITableView, group: GroupAdminData) {
        self.group = group
        super.init()
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(PPImagePostCell.nib, forCellReuseIdentifier: PPImagePostCell.identifier)
        tableView.register(PPTextWithBgPostCell.nib, forCellReuseIdentifier: PPTextWithBgPostCell.identifier)
        tableView.register(PPTextPostCell.nib, forCellReuseIdentifier: PPTextPostCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

// MARK: - Actions
extension PendingPostsdapter {
   
    @objc func didTapProfileButton(_ sender: UIButton) {
        guard let user = group.pendingPosts?.object(at: sender.tag)?.user else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    @objc func didTapApproveButton(_ sender: TransitionButton) {
        guard let p = group.pendingPosts?.object(at: sender.tag) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
        
        sender.startAnimation()
        cell?.isUserInteractionEnabled = false
        update(post:p, action: .acceptGroupPost) { [weak self] status in
            cell?.isUserInteractionEnabled = true
            sender.stopAnimation()
            
            if status == true {
                self?.group.pendingPosts?.remove(at: sender.tag)
                self?.tableView.reloadData()
            }
            
        }
    }
    @objc func didTapDeclineButton(_ sender: TransitionButton) {
        guard let p = group.pendingPosts?.object(at: sender.tag) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
        
        sender.startAnimation()
        cell?.isUserInteractionEnabled = false
        update(post:p, action: .removeGroupPost) { [weak self] status in
            cell?.isUserInteractionEnabled = true
            sender.stopAnimation()
            
            if status == true {
                self?.group.pendingPosts?.remove(at: sender.tag)
                self?.tableView.reloadData()
            }
            
        }
    }
    
}


// MARK: - TableView DataSource & Delegate
extension PendingPostsdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }
        return group.pendingPosts?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isLoading ? 260 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: PPTextPostCell.identifier, for: indexPath) as! PPTextPostCell
            cell.beginSkeltonAnimation()
            return cell
        }
        
        
        let post = group.pendingPosts?.object(at: indexPath.row)
        
        if (post?.postAsset?.images?.count ?? 0) > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PPImagePostCell.identifier, for: indexPath) as! PPImagePostCell
            cell.setData(post)
            cell.btnProfile.tag = indexPath.row
            cell.btnApprove.tag = indexPath.row
            cell.btnDecline.tag = indexPath.row
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnApprove.addTarget(self, action: #selector(didTapApproveButton(_:)), for: .touchUpInside)
            cell.btnDecline.addTarget(self, action: #selector(didTapDeclineButton(_:)), for: .touchUpInside)
            return cell
        } else if post?.isBackground == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: PPTextWithBgPostCell.identifier, for: indexPath) as! PPTextWithBgPostCell
            cell.setData(post)
            cell.btnProfile.tag = indexPath.row
            cell.btnApprove.tag = indexPath.row
            cell.btnDecline.tag = indexPath.row
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnApprove.addTarget(self, action: #selector(didTapApproveButton(_:)), for: .touchUpInside)
            cell.btnDecline.addTarget(self, action: #selector(didTapDeclineButton(_:)), for: .touchUpInside)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: PPTextPostCell.identifier, for: indexPath) as! PPTextPostCell
        if let p = post {
            cell.setData(p)
        } else {
            cell.beginSkeltonAnimation()
        }
        cell.btnProfile.tag = indexPath.row
        cell.btnApprove.tag = indexPath.row
        cell.btnDecline.tag = indexPath.row
        cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
        cell.btnApprove.addTarget(self, action: #selector(didTapApproveButton(_:)), for: .touchUpInside)
        cell.btnDecline.addTarget(self, action: #selector(didTapDeclineButton(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension PendingPostsdapter {
    func update(post: Post, action: GroupAdminAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let gId = group.groupID else { return }
        
        APIManager.social.updateGroupPost(groupId: gId, postId: post.postID, action: action) { [weak self] error in
            if error == nil {
                completion(true)
            } else {
                self?.parent?.showErrorWith(message: error!.message)
                completion(false)
            }
        }
        
    }
}
