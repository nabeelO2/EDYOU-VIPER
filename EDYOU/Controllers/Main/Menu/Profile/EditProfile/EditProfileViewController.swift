//
//  EditProfileViewController.swift
//  EDYOU
//
//  Created by Admin on 13/06/2022.
//

import UIKit
import TransitionButton
class EditProfileViewController: BaseController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var tblSocailLinks: UITableView!
    @IBOutlet weak var tblProfilePictures: UITableView!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var isShowMessageButton: UISwitch!
    @IBOutlet weak var isShowCallButton: UISwitch!
    @IBOutlet weak var hireMe: UISwitch!
    @IBOutlet weak var isPrivateAccount: UISwitch!
    @IBOutlet weak var txtEmail: BorderedTextField!
    @IBOutlet weak var firstName: BorderedTextField!
    @IBOutlet weak var lastName: BorderedTextField!

    @IBOutlet weak var txtLocation: BorderedTextField!
    @IBOutlet weak var txtUniversity: BorderedTextField!
    @IBOutlet weak var txtClassYear: BorderedTextField!
    @IBOutlet weak var txtBirthday: BorderedTextField!
    @IBOutlet weak var txtLanguaage: BorderedTextField!
    @IBOutlet weak var txtGender: BorderedTextField!
    @IBOutlet weak var cntProfile: UIView!
    var selectedGender : String = ""

    var selectedSegmentIndex = 0
    var socialLinks: [String:String] = [:]
    
    var adapter:EditProfileAdapter!
    var type: EditProfileTableViewType = .profilePhoto
    var user:User
    var isDirtyData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        adapter = EditProfileAdapter(tableView: tblProfilePictures, tableType: .profilePhoto, user: user)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadUserData()
    }
    
    
    func loadUserData() {
        APIManager.social.getUserInfo {[weak self] user, error in
            guard let self = self else { return }
            if let u = user {
                self.user = u
                self.extractSocialLinks()
                self.adapter.updateUserInAdapter(user: u)
                self.tblProfilePictures.reloadData()
            } else {
                self.showErrorWith(message: error?.message ?? "Unexpected error")
            }
        }
    }
    
    init(user:User){
        
        self.user = user
        super.init(nibName: EditProfileViewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.user = User.nilUser
        super.init(coder: coder)
        
    }
    
    func setUpView() {
        tblProfilePictures.isHidden = false
        cntProfile.isHidden = !tblProfilePictures.isHidden
        txtLanguaage.text = user.languages.joined(separator: ", ")
        firstName.text = user.name?.firstName
        lastName.text = user.name?.lastName

        txtEmail.text = user.email
        txtGender.text = user.gender
        txtGender.text = getGender().capitalized
        txtLocation.text = user.addresses.first?.addressLocality
        if (user.education.count > 0) {
            txtUniversity.text = user.education.first?.instituteName
        }
        hireMe.isOn = user.hireMe 
        isPrivateAccount.isOn = user.isPrivate 
        isShowCallButton.isOn = user.isCallAllowed 
        isShowMessageButton.isOn = user.isMessageAllowed 
        hireMe.addTarget(self, action: #selector(didHireMe), for: .allEvents)
        isPrivateAccount.addTarget(self, action: #selector(didPrivateAccount), for: .allEvents)
        isShowCallButton.addTarget(self, action: #selector(didShowCallButton), for: .allEvents)
        isShowMessageButton.addTarget(self, action: #selector(didShowMessageButton), for: .allEvents)
        self.txtBirthday.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: self.user.dateOfBirth?.toDate)
        self.txtUniversity.text = self.user.getCurrentEducation()?.instituteName
        self.txtClassYear.setupDatePicker(maximumDate: Date(), minimumDate: nil, dateFormat: "yyyy", selectedDate: self.user.getCurrentEducation()?.degreeEnd?.toDate)
        self.firstName.textField.delegate = self
        self.lastName.textField.delegate = self
        self.txtLocation.textField.delegate = self
        self.txtBirthday.textField.delegate = self
    }
    
    @objc func didHireMe(mySwitch: UISwitch){
        let status = mySwitch.isOn
        updateHireMe(status:status)
        
    }
    @objc func didPrivateAccount(mySwitch: UISwitch){
        let status = mySwitch.isOn
        updateAccountPrivate(status: status)
    }
    
    @objc func didShowCallButton(mySwitch: UISwitch){
        let status = mySwitch.isOn
        updateCallMe(status: status)
    }
    @objc func didShowMessageButton(mySwitch: UISwitch){
        let status = mySwitch.isOn
        updateMessageMe(status: status)
    }
    @IBAction func didChangeSegments(_ sender: UISegmentedControl) {
        if isDirtyData {
            showConfirmationAlert(title: "Confirmation", description: "You unsaved changes will be lost? Please tap save option", buttonTitle: "Confirm", style: .default) {
                self.isDirtyData = false
                self.selectedSegmentIndex = sender.selectedSegmentIndex
                switch sender.selectedSegmentIndex {
                case 0:
                    self.uploadUserCoverPhotos()
                    break
                case 1:
                    self.updateInfo(animateButton: true)
                    break
                case 2:
                    self.extractSocialLinks()
                    break
                default:
                    break
                }
                self.onSegmentChange(sender)
            } onCancel: {
                self.segmentedControl.selectedSegmentIndex = self.selectedSegmentIndex
            }
        } else {
            onSegmentChange(sender)
        }
        
    }
    
    func onSegmentChange(_ sender: UISegmentedControl) {
        tblProfilePictures.isHidden = sender.selectedSegmentIndex == 1
        cntProfile.isHidden = !tblProfilePictures.isHidden
        selectedSegmentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            adapter = EditProfileAdapter(tableView: tblProfilePictures, tableType: .profilePhoto, user: user)
        case 2:
            adapter = EditProfileAdapter(tableView: tblSocailLinks, tableType: .socialLinks,user: user)
        default:
            return
        }
        tblProfilePictures.reloadData()
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        if isDirtyData {
            showConfirmationAlert(title: "Are you sure", description: "You unsaved changes will be lost? Please tap save option", buttonTitle: "Confirm", style: .default) {
                self.goBack()
            } onCancel: {
                
            }
        } else {
            goBack()
        }
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        switch selectedSegmentIndex {
        case 0:
            uploadUserCoverPhotos()
            break
        case 1:
            let validated = validate()
            if validated {
                updateInfo(animateButton: true)
            } else {
                sender.shake()
            }
            break
        case 2:
            updateSocialLinks(links: self.socialLinks)
            break
        default:
            break
        }
    }
    
    @IBAction func didTapGender(_ sender: Any) {
        self.isDirtyData = true
        
        let genderPicker = ReusbaleOptionSelectionController(options:  ["Male", "Female", "Another gender identity", "Prefer not to say"], previouslySelectedOption: self.selectedGender, screenName: "Select Gender", completion: { selected in
            self.selectedGender = selected
            self.txtGender.text = selected
        })
        
        self.presentPanModal(genderPicker)
        
    }
    
    // MARK: -  Others
    func getGender() -> String
    {
        if txtGender.text == "Another gender identity"
        {
            return "another_gender_identity"
        }
        else
        if txtGender.text == "Prefer not to say"
        {
            return "prefer_not_to_say"
        }
        else
        if txtGender.text == "prefer_not_to_say"
        {
            return "Prefer not to say"
        }
        else
        if txtGender.text == "another_gender_identity"
        {
            return "Another gender identity"
        }
        else
        {
            return txtGender.text?.lowercased() ?? "male"
        }
    }
    @IBAction func didTapLanguage(_ sender: Any) {
        self.isDirtyData = true
        let controller = TextInputController(title: "Language", currentText: txtLanguaage.text ?? "", multiline: false) { [weak self] text in
            self?.txtLanguaage.text = text
            self?.view.layoutIfNeeded()
        }
        self.present(controller, animated: true, completion: nil)
    }
    
   
}

extension EditProfileViewController{
    
    func validate() -> Bool {
        var status = true
        if self.firstName.text.isTrimmedEmpty()
            || self.lastName.text.isTrimmedEmpty()
            || String(format:"%@",getGender()).isEmpty
            {
            status = false
        }
        return status
    }
    
    func updateInfo(animateButton: Bool = true) {
        var parameters: [String: Any] = [
            "gender": String(format:"%@",getGender()),
            "languages": [txtLanguaage.text ?? ""],
            "institute_name": txtUniversity.text ?? "",
            "name": [
                "first_name": firstName.text ?? "",
                "last_name": lastName.text ?? ""
            ]
            
        ]
        
      
        let address: [String:String] = [
            "address_locality" : txtLocation.text ?? ""
        ]
        
        if let d = self.txtBirthday.selectedDate {
            parameters["date_of_birth"] = [
                "birth_year": d.stringValue(format: "yyyy"),
                "birth_month": d.stringValue(format: "MM"),
                "birth_date": d.stringValue(format: "dd")
            ]
        }
        parameters["addresses"] = [address]
        
        view.endEditing(true)
        if animateButton {
            btnSave.startAnimation()
        }
        view.isUserInteractionEnabled = false
        APIManager.social.updateProfile(parameters) { [weak self] response, error in
            guard let self = self else { return }
            self.btnSave.stopAnimation()
            self.isDirtyData = false
            self.view.isUserInteractionEnabled = true
            if error == nil {
                self.loadUserAndResetDirty()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func updateHireMe(status:Bool){
        APIManager.social.updateHireMe(status: status, completion: self.processToggleResponse)
    }
    func updateAccountPrivate(status:Bool){
        APIManager.social.updatePrivateAccount(status: status, completion: self.processToggleResponse)
    }
    
    func updateCallMe(status:Bool){
        APIManager.social.updateCallMe(status: status, completion: self.processToggleResponse)
    }
    
    func updateMessageMe(status:Bool){
        APIManager.social.updateMessageMe(status: status, completion: self.processToggleResponse)
    }
    
    private func processToggleResponse(response: GeneralResponse?, error: ErrorResponse?) {
        if error == nil {
            self.loadUserData()
        } else {
            self.showErrorWith(message: error!.message)
        }
    }
    
    func didChangeSocialLink(socialLinks: [PostSocialLinkData]) {
        for socialLink in socialLinks where socialLink.socialHandle.isEmpty == false {
            self.socialLinks[socialLink.name] = socialLink.socialHandle
        }
        self.isDirtyData = true
    }
    
    func removeSocialLink(_ value: PostSocialLinkData) {
        self.socialLinks.removeValue(forKey: value.name)
        self.isDirtyData = true
    }
    
    func updateSocialLinks(links: [String:String]){
        var parameters : [[String:String]] = []
        for (key,val) in links {
            parameters.append(["social_network_name":key , "social_network_url":val])
        }
        self.btnSave.startAnimation()
        APIManager.fileUploader.userSocialLinks(parameters: parameters) { user, error in
            self.btnSave.stopAnimation()
            if error == nil {
                self.loadUserAndResetDirty()
            } else {
                BaseController().showErrorWith(message: error!.message)
            }
        }
    }
    
    private func extractSocialLinks() {
        for links in self.user.socialLinks
        {
            self.socialLinks[links.socialNetworkName!] = links.socialNetworkURL
        }
    }
}

extension EditProfileViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isDirtyData = true
    }
}

extension EditProfileViewController {
    
    func uploadUserCoverPhotos() {
        var media : [Media] = []
        for coverPhoto in self.adapter.coverPhotos where coverPhoto.localImage != nil {
            media.append(Media(withImage: UIImage.init(data: coverPhoto.localImage!)!, key: "files")!)
        }
        if media.count == 0 {
            return
        }
        self.uploadCoverImage(media: media, animateButton: true)
    }
    
    private func uploadCoverImage(media: [Media], animateButton: Bool = true) {
        
        self.view.isUserInteractionEnabled = false
        if animateButton {
            btnSave.startAnimation()
        }
        
        APIManager.fileUploader.uploadCoverImage(media: media) { [weak self] progress in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            print("progress: \(progress)")
        } completion: { [weak self] response, error in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.btnSave.stopAnimation()
            if error != nil {
                self.showErrorWith(message: error!.message)
            } else {
                self.loadUserAndResetDirty()
            }
        }
    }
}

extension EditProfileViewController {
    func loadUserAndResetDirty() {
        self.isDirtyData = false
        self.loadUserData()
    }
}
