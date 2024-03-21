//
//  ProfessionalProfileController.swift
//  EDYOU
//
//  Created by Admin on 06/06/2022.
//

import UIKit

class ProfessionalProfileController: BaseController {
    
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var profileTitle:String?
    var user: User!
    //    var adapter: UserProfileAdapter!
    var media = [Media]()
    var type: AboutSections = .experiences
    var aboutFactory: AboutFactory!
    var friendshipStatus: FriendShipStatusModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTittle.text = profileTitle
        self.aboutFactory = AboutFactory(table: self.tableView, navigationController: self.navigationController)
        self.aboutFactory.user = user!
        self.friendshipStatus = FriendShipStatusModel(friendID: user.userID, friendRequestStatus: FriendShipStatus.unknown, requestOrigin: .sent)
        setUpView()
        
    }
    func setUpView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchProfileData()
    }
    
    @objc func didTapEditCertificate(sender:UIButton){
        let controller = CertificateController(userCertificate: (user?.userCertifications[sender.tag])!)
        self.present(controller, animated: true, completion: nil)
        print("Tapped")
        
    }
    
    init(tittle:String, user:User, type: AboutSections) {
        self.profileTitle =  tittle
        self.user = user
        self.type = type
        super.init(nibName: ProfessionalProfileController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    deinit {
        print("[ProfessionalProfileController] deinit")
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        let controller = self.type.getController(data: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfessionalProfileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aboutFactory.tableView(numberOfRowsInSection: self.type.rawValue, user: self.user, isEditMode: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.aboutFactory.tableView(cellForRowAt: IndexPath(row: indexPath.row, section: self.type.rawValue), friendshipStatus: self.friendshipStatus, user: self.user, delegate: self)
        return cell
    }
}

extension ProfessionalProfileController {
    
    func fetchProfileData() {
        self.getUserDetails()
    }
    
    func getUserDetails(completion: (() -> Void)? = nil) {
        var userId: String? = user?.userID
        if user?.userID?.count == 0 || user?.userID == Cache.shared.user?.userID {
            userId = nil
        }
        APIManager.social.getUserInfo(userId: userId) { [weak self] user, error in
            guard let self = self else { return }
            if let u = user {
                self.user = u
                self.aboutFactory.user = user!
                self.tableView.reloadData()
            } else {
                self.showErrorWith(message: error?.message ?? "Unexpected error")
            }
        }
    }
    
    func deleteProfileItem(id:String) {
        self.handleViewLoading(enable: false)
        ProfileNetworkHelper.shared.deleteFromProfile(id: id, type: type) { err in
            self.handleViewLoading(enable: true)
            if let err = err {
                self.showErrorWith(message: err.message)
                return
            }
            self.getUserDetails()
        }
    }
}

extension ProfessionalProfileController: AboutSectionCellDelegate {
    func onEdit(index: Int) {
        var data: Any?
        switch type {
        case .experiences:
            data = self.user.workExperiences.toArray(type: WorkExperience.self).object(at:index)
            break
        case .about:
            break
        case .education:
            data = self.user.education.toArray(type: Education.self).object(at:index)
        case .certificates:
            data = self.user.userCertifications.toArray(type: UserCertification.self).object(at:index)
        case .skills:
            data = self.user.skills.toArray(type: String.self).object(at:index)
        case .documents:
            data = self.user.userDocuments.toArray(type: UserDocument.self).object(at:index)
        }
        if let userData = data {
            let controller = self.type.getController(data: userData)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func onDelete(index: Int) {
        self.showConfirmationAlert(index: index)
        self.tableView.reloadData()
    }
    
    func showConfirmationAlert(index: Int) {
        self.showConfirmationAlert(title: "Are you sure?", description: "Are you sure you want to delete this.", buttonTitle: "Delete", style: .destructive) {
            self.proccessDeleteRequest(index: index)
        }
    }
    
    private func proccessDeleteRequest(index: Int) {
        var idToDelete: String?
        switch type {
        case .about:
            break
        case .experiences:
            idToDelete = self.user.workExperiences.toArray(type: WorkExperience.self).object(at: index)?.companyID
            self.user.workExperiences.remove(at: index)
            break
        case .education:
            idToDelete = self.user.education.toArray(type: Education.self).object(at: index)?.educationId
            self.user.education.remove(at: index)
            break
        case .certificates:
            idToDelete = self.user.userCertifications.toArray(type: UserCertification.self).object(at: index)?.certificationID
            self.user.userCertifications.remove(at: index)
            break
        case .skills:
            idToDelete = self.user.skills[index]
            self.user.skills.remove(at: index)
            break
        case .documents:
            idToDelete = self.user.userDocuments.toArray(type: UserDocument.self).object(at: index)?.documentID
            self.user.userDocuments.remove(at: index)
            break
        }
        self.sendDeleteRequest(id: idToDelete ?? "-1")
        self.tableView.reloadData()
    }
    
    private func sendDeleteRequest(id: String) {
        if id == "-1" {
            self.reloadIfError(message: "Something went wrong. Please try again later")
            return
        }
        ProfileNetworkHelper.shared.deleteFromProfile(id: id, type: self.type) { err in
//            guard let self = self else { return }
            self.handleError(error: err)
            if let err = err {
                self.showErrorWith(message: err.message)
                self.goBack()
            }
        }
    }
    
    private func reloadIfError(message: String) {
        self.showErrorWith(message: message)
        self.getUserDetails()
    }
}
