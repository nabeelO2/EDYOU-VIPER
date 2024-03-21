//
//  StoriesCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit

protocol StoriesCellDelegate {
    func viewStories(stories: [Story], indexPath: IndexPath)
}

class StoriesCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var VBorderGradient: GradientView!
    @IBOutlet weak var vGradientContainer: UIView!
    
    var stories = [Story]()
    var parent: HomeController?
    var tabPersonalProfile : (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        
//        imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
        collectionView.register(StoryItemCell.nib, forCellWithReuseIdentifier: StoryItemCell.identifier)
        
        collectionView.register(MyStoriesCell.nib, forCellWithReuseIdentifier: MyStoriesCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
//        imgProfile.round()
//        imgProfile.borderWidth = 2.0
//        imgProfile.borderColor = R.color.background()
        // TODO : When color is generated
        let gradient = GradientShades.getProfileGradient
        self.VBorderGradient.colors = [ gradient.start, gradient.end]
        self.VBorderGradient.round()
        
    }
    
}

extension StoriesCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 102, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyStoriesCell.identifier, for: indexPath) as! MyStoriesCell
            
            cell.imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
            cell.imgProfile.round()
            cell.imgProfile.borderWidth = 2.0
            cell.imgProfile.borderColor = R.color.background()
            
            let gradient = GradientShades.getProfileGradient
            cell.VBorderGradient.colors = [ gradient.start, gradient.end]
            cell.VBorderGradient.round()
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryItemCell.identifier, for: indexPath) as! StoryItemCell
            
            cell.imgProfile.setImage(url: stories[indexPath.row-1].user.profileImage, placeholder: R.image.profile_image_dummy())
            cell.lblName.text = stories[indexPath.row-1].user.name?.firstName ?? stories[indexPath.row-1].user.name?.lastName
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
           
            if let action = tabPersonalProfile{
                action()
            }
        }
        else{
            let controller = ShowStoriesController()
            let navigationController = UINavigationController(rootViewController: controller)
            controller.selectedIndex = indexPath.row-1
            controller.stories = stories
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.isHidden = true
    //        parent?.navigationController?.pushViewController(controller, animated: true)
            
    //        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            
            parent?.navigationController?.present(navigationController, animated: true, completion: nil)
        }
       

    }
}
