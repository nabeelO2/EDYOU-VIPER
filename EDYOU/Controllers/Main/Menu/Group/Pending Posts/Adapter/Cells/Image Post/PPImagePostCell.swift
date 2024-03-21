//
//  PPImagePostCell.swift
//  EDYOU
//
//  Created by  Mac on 08/09/2021.
//

import UIKit
import ActiveLabel
import TransitionButton

class PPImagePostCell: UITableViewCell {

    
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnApprove: TransitionButton!
    @IBOutlet weak var btnDecline: TransitionButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var images = [String]()
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        pageControl.numberOfPages = 10
        pageControl.currentPage = 0
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setData(_ data: Post?) {
        self.post = data
        imgProfile.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = data?.user?.name?.completeName ?? "N/A"
        lblInstituteName.text = data?.user?.college ?? "N/A"
        lblPost.text = data?.formattedText
        
        images = data?.postAsset?.images ?? []
        pageControl.numberOfPages = images.count
        collectionView.reloadData()
        lblPost.handleMentionTap { [weak self] tappedName in
            guard let self = self else { return }
            
            for u in (self.post?.tagFriendsProfile ?? []) {
                if let user = u {
                    let name = user.formattedUserName
                    if name == tappedName {
                        let controller = ProfileController(user: user)
                        let navC = self.viewContainingController()?.tabBarController?.navigationController ?? self.viewContainingController()?.navigationController
                        navC?.popToRootViewController(animated: false)

                        navC?.pushViewController(controller, animated: true)
                    }
                }
                
            }
        }
        
    }
    
}

extension PPImagePostCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell
        cell.imgPost.setImage(url: images[indexPath.row], placeholderColor: R.color.image_placeholder() ?? .lightGray)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let post = self.post {
            let controller = PostDetailsController(post: post, prefilledComment: nil)
            let navC = self.viewContainingController()?.tabBarController?.navigationController ?? self.viewContainingController()?.navigationController
            navC?.pushViewController(controller, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
            pageControl.currentPage = pageNumber
        }
    }
}
