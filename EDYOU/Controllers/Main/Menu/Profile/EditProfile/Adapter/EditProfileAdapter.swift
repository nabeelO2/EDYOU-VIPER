//
//  EditProfileAdapter.swift
//  EDYOU
//
//  Created by Admin on 21/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class PostSocialLinkData {
    var name: String
    var socialHandle: String
    var enableToEdit: Bool = false
    var image: UIImage? = nil
    internal init(name: String, socialHandle: String) {
        self.name = name
        self.socialHandle = socialHandle
    }
    static var NilData: PostSocialLinkData {
        PostSocialLinkData(name: "", socialHandle: "")
    }
}

class EditProfileAdapter: NSObject {
    
    var tableView: UITableView
    var tableType: EditProfileTableViewType
    var links: [SocialLinkNetwork] = SocialLinkNetwork.allCases
    var parent: EditProfileViewController? {
        return tableView.viewContainingController() as? EditProfileViewController
    }
    var user:User
    var media = [Media]()
    var socialLinks: [PostSocialLinkData] = []
    var coverPhotos: [CoverPhoto] = []
    init(tableView: UITableView, tableType: EditProfileTableViewType,user:User){
        self.tableView = tableView
        self.tableType = tableType
        self.user = user
        super.init()
        self.mapSocialLinks()
        configure()
        self.updateCoverPhotos(user: user)
    }
    
    func configure(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EditProfileImageCell.nib, forCellReuseIdentifier: EditProfileImageCell.identifier)
        tableView.register(EditProfileCoverPhotoCell.nib, forCellReuseIdentifier: EditProfileCoverPhotoCell.identifier)
        tableView.register(ProfileSocialLinks.nib, forCellReuseIdentifier: ProfileSocialLinks.identifier)
        tableView.register(ProfileAboutHeader.nib, forCellReuseIdentifier: ProfileAboutHeader.identifier)
        tableView.register(EmptyTableCell.nib, forCellReuseIdentifier: EmptyTableCell.identifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
 
    func updateUserInAdapter(user: User) {
        self.socialLinksUpdated(user: user)
        self.updateCoverPhotos(user: user)
    }
    
    private func socialLinksUpdated(user: User) {
        self.user = user
        self.mapSocialLinks()
    }
    
    private func mapSocialLinks() {
        let savedLinks = user.socialLinks.toArray(type: SocialLink.self)
        for link in links {
            let linkValue = savedLinks.first(where: {$0.socialNetworkName == link.name})?.socialNetworkURL ?? ""
            let postLinks = PostSocialLinkData(name: link.name, socialHandle: linkValue)
            postLinks.image = link.icon
            self.socialLinks.append(postLinks)
        }
    }
    
    private func updateCoverPhotos(user: User) {
        self.coverPhotos = user.coverPhotosArray.detached()
    }
}



// MARK: - TableView Setup

extension EditProfileAdapter: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableType{
        case .profilePhoto:
            return 2
        case .socialLinks:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableType {
            
        case .profilePhoto:
            let type = ProfileImageType(rawValue: section)
            if type == .displayPhoto { return 1 }
            if type == .coverPhoto {
                return self.coverPhotos.isEmpty ? 1 : self.coverPhotos.count
            }
        case .socialLinks:
            return links.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableType {
        case .profilePhoto:
            let type = ProfileImageType(rawValue: indexPath.section)
            if type == .displayPhoto {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileImageCell.identifier, for: indexPath) as! EditProfileImageCell
                cell.imgProfile.setImage(url: user.profileImage, placeholder: R.image.dm_profile_holder()!)
                cell.btnEdit.addTarget(self, action: #selector(didTapEditProfile(_:)), for: .touchUpInside)
                return cell
            }
            if type == .coverPhoto {
                if self.coverPhotos.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier) as! EmptyTableCell
                    cell.setConfiguration(configuration: .coverPhoto)
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileCoverPhotoCell.identifier, for: indexPath) as! EditProfileCoverPhotoCell
                cell.setCoverImage(coverImage: self.coverPhotos[indexPath.row])
                cell.btnEdit.addTarget(self, action: #selector(removeCoverPhoto(sender:)), for: .touchUpInside)
                cell.btnEdit.tag = indexPath.row
                return cell
            }
            
        case .socialLinks:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSocialLinks.identifier, for: indexPath) as! ProfileSocialLinks
            cell.setData(socialLink: self.socialLinks[indexPath.row], indexPath: indexPath)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch tableType {
        case .profilePhoto:
            let type = ProfileImageType(rawValue: section)
            if  type == .coverPhoto {
                let headerView = tableView.dequeueReusableCell(withIdentifier: ProfileAboutHeader.identifier) as! ProfileAboutHeader
                headerView.setupHeader(title: "Cover Photo", isAbout: false)
                headerView.btnAdd.addTarget(self, action: #selector(didTapAddCoverAction(sender:)), for: .touchUpInside)
                headerView.btnEdit.isHidden = true
                return headerView
            }
        case .socialLinks:
            return nil
        }
       return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 { return 55 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableType == .socialLinks {
//            let network = links.object(at: indexPath.row)!
//            let link = (socialLinks.filter({ item in
//                item.name.lowercased() == network.name.lowercased()
//            }).first) ?? PostSocialLinkData.NilData
//            if link.socialHandle.isEmpty {
//                return 55
//            } else {
//                return 95
//            }
//        }
        
        return UITableView.automaticDimension
    }
    
    @objc func didTapAddCoverAction(sender: UIButton) {
        ImagePicker.shared.open(self.parent!, title: "Cover Photo", message: nil) { [weak self] data in
            guard let image = data.image , let self = self else { return }
            
            let scaledImage = image.aspectFittedToHeight(300)
            let coverPhoto = CoverPhoto.nilCoverPhoto
            coverPhoto.localImage = scaledImage.jpeg(.medium)
            self.coverPhotos.append(coverPhoto)
            self.reloadCoverData()
        }
    }
    
    func reloadCoverData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.tableView.reloadData()
            self.parent?.isDirtyData = true
        }
    }
    
    @objc func removeCoverPhoto(sender: UIButton) {
        if !(self.coverPhotos.count > sender.tag) {
            return
        }
        self.showConfirmationForDelete(index: sender.tag)
    }
    
    private func showConfirmationForDelete(index: Int) {
        self.parent?.showConfirmationAlert(title: "Are you sure?", description: "Do you want to delete this cover photo", buttonTitle: "Delete", style: .destructive, onConfirm: {
            self.sendRemoveCoverPhotoRequest(index: index)
        }, onCancel: nil)
    }
    
    private func sendRemoveCoverPhotoRequest(index: Int) {
        let coverPhotoId = self.coverPhotos[index].coverPhotoID ?? ""
        if coverPhotoId.isEmpty {
            //remove local images
            self.coverPhotos.remove(at: index)
            self.tableView.reloadData()
            return
        }
        
        APIManager.social.deleteCoverPhoto(coverId: coverPhotoId) { error in
            if let err = error {
                self.parent?.showErrorWith(message: err.message)
            } else {
                self.user.coverPhotos.remove(at: index)
                self.coverPhotos.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
}


extension EditProfileAdapter {
    @objc func didTapEditProfile(_ sender:UIButton){
        let controller = EditProfilePhoto(photo: user.profileImage ?? "", image: R.image.dm_profile_holder()!) //EditProfilePhoto(photo: user.profileImage ?? "", image: UIImage())
        controller.modalPresentationStyle = .fullScreen
        self.parent?.present(controller, animated: true, completion: nil)
    }
}
extension EditProfileAdapter:SocialLinkAction {
   
    
    func tapLinkOption(_ indexPath: IndexPath) {
        self.socialLinks[indexPath.row].enableToEdit = true
        print(socialLinks)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func deleteSocialLink(indexPath: IndexPath) {
        self.socialLinks[indexPath.row].enableToEdit = false
        self.socialLinks[indexPath.row].socialHandle = ""
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.parent?.removeSocialLink(self.socialLinks[indexPath.row])
    }
    func didUpdateSocialLink(indexPath: IndexPath, value: String) {
        self.socialLinks[indexPath.row].socialHandle = value
        self.parent?.didChangeSocialLink(socialLinks: self.socialLinks)
    }
    
}
