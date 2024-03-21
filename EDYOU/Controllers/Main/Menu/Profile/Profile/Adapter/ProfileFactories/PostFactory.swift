//
//  PostFactory.swift
//  EDYOU
//
//  Created by Masroor on 18/06/2022.
//

import Foundation
import UIKit
protocol PostFactoryActions : AnyObject {
    func tapGroupButton(sender: Int)
    func tapProfileButton(sender: Int)
    func tapMoreButton(sender: Int)
}


public class PostFactory {
    var tableView: UITableView!
    weak var delegate: PostCellActions?
    weak var factoryDelegate: PostFactoryActions?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        registerCells()
    }
    
    func updateDelegate(delegate: PostCellActions, factoryDelegate: PostFactoryActions) {
        self.delegate = delegate
        self.factoryDelegate = factoryDelegate
    }
    
    private func registerCells() {
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(NoPostsCell.nib, forCellReuseIdentifier: NoPostsCell.identifier)
        tableView.register(NoMorePostCell.nib, forCellReuseIdentifier: NoMorePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        self.tableView.register(EmptyTableCell.nib, forCellReuseIdentifier: EmptyTableCell.identifier)
    }
    
    func numberOfSections() -> Int {
        return 0
    }
    
    func tableView(numberOfRowsInSection section: Int, posts: [Post] , showSkeleton: Bool) -> Int {
        if showSkeleton {
            return 5
        } else if posts.count == 0 {
            return 1
        } else {
            return posts.count
        }
    }
    
    func tableView(heightForRowAt indexPath: IndexPath,showSkeleton: Bool) -> CGFloat {
        if showSkeleton {
            return 260
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func getCell(posts: [Post], indexPath: IndexPath, totalRecord: Int,showSkeleton: Bool) -> UITableViewCell {
        if showSkeleton {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            cell.beginSkeltonAnimation()
            return cell
        }
        if posts.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath) as! EmptyTableCell
            cell.setConfiguration(configuration: EmptyCellConfirguration.posts)
            return cell
        }
        let post = posts[indexPath.row]
        if (post.medias.count ) > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier, for: indexPath) as! ImagePostCell
            let dimenstion = post.medias.first?.url.getDimenstions()
            let w = Double(dimenstion?.0 ?? 0)
            let h = Double(dimenstion?.1 ?? 0)
            print(dimenstion)
            let ratio = h > 0 ? Double(h / w) : Double(1.1)
            let width = Double(tableView.frame.width ?? 300)
            var height =  width * ratio
            if height == 0 {
                height = width * 1.1
            }
//                cell.setCVDimenstion(height, width)
//                cell.collectionVW.constant = width
            cell.collectionVH.constant = height
            cell.setData(post)
            cell.actionDelegate = delegate
            cell.indexPath = indexPath
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            
            return cell
        } else if post.isBackground == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextWithBgPostCell.identifier, for: indexPath) as! TextWithBgPostCell
            cell.setData(post)
            cell.actionDelegate = delegate
            cell.indexPath = indexPath
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
        cell.actionDelegate = delegate
        
        if indexPath.row >= posts.count {
            
            if totalRecord == posts.count {//&& isLoading == false {
                if posts.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoPostsCell.identifier, for: indexPath) as! NoPostsCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoMorePostCell.identifier, for: indexPath) as! NoMorePostCell
                    return cell
                }
            }
            
            cell.beginSkeltonAnimation()
            return cell
        }
        else {
            cell.setData(post)
        }
        cell.indexPath = indexPath
        cell.actionDelegate = delegate
        cell.btnMore.tag = indexPath.row
        cell.btnProfile.tag = indexPath.row
        cell.btnGroupName.tag = indexPath.row
        cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
        cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func didTapProfileButton(_ sender: UIButton) {
        self.factoryDelegate?.tapProfileButton(sender: sender.tag)
    }
    @objc func didTapMoreButton(_ sender: UIButton) {
        self.factoryDelegate?.tapMoreButton(sender: sender.tag)
    }
    @objc func didTapGroupButton(_ sender: UIButton) {
        self.factoryDelegate?.tapGroupButton(sender: sender.tag)
    }
}
