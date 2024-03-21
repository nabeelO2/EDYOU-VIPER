//
//  PostCell.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit
import ActiveLabel

protocol PostCell {
    var imgProfile: UIImageView! { get set }
    var lblName: UILabel! { get set }
    var lblInstituteName: UILabel! { get set }
    var lblPost: ActiveLabel! { get set }
    var imgLike: UIImageView! { get set }
    var lblLikes: UILabel! { get set }
    var imgComment: UIImageView! { get set }
    var lblComments: UILabel! { get set }
    func setData(_ data: Post?)
    func addReaction(_ reaction: PostLike?, totalReactions: Int)
    func updatePostData(data: Post?)
}

protocol PostCellActions :  AnyObject {
    func showReactionPanel(indexPath: IndexPath, postId: String)
    func tapOnReaction(indexPath: IndexPath, reaction: String)
    func tapOnComments(indexPath: IndexPath, comment: String?)
    func showAllReactions(indexPath: IndexPath, postId: String)
    func manageFavorites(indexPath: IndexPath, postId: String)
}
