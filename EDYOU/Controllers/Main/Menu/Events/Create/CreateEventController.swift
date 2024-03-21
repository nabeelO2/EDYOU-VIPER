//
//  CreateEventController.swift
//  EDYOU
//
//  Created by  Mac on 16/09/2021.
//

import UIKit
import TransitionButton
import CoreMedia

class CreateEventController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var createOrUpdateNavTitle: UILabel!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var btnCreate: TransitionButton!
    @IBOutlet weak var imgEventPhoto: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var viewContainerDescription: UIView!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtDressCode: UITextField!
    @IBOutlet weak var txtPrivacy: UITextField!
    @IBOutlet weak var txtEventType: UITextField!
    @IBOutlet weak var inviterName: UITextField!
   // @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var placeHolderImage: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var chooseImageBtn: UIButton!
    @IBOutlet weak var guestListVisibleSwitch: UISwitch!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var anyoneCanInviteSwitch: UISwitch!
    @IBOutlet weak var locationOrWebURLTitleLbl: UILabel!
    @IBOutlet weak var clearTextButton: UIButton!
    
    
    // MARK: - Properties
    var eventPhoto: UIImage?
    var selectedLocation: EventLocation?
    var startDate: Date?
    var endDate: Date?
    var category: String?
    var dressCode: String?
    var eventType: EventType?
    var eventPrivacy: EventPrivacy?
    
    var selectedFriends = [User]()
    var selectedGroup: Group?
    var eventEdit = false
    var event : Event?
    var uploadUrl: String?
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
//        setupDatePicker()
        imageContainerView.setShadow()
        chooseImageBtn.setShadow()
        txtTitle.delegate = self
        
        if (eventEdit) {
            setData()
        } else {
            
            let user = User.me
            inviterName.text = user.name?.completeName
            
            clearTextButton.isHidden = true
        }
    }
//    func setupDatePicker() {
//
//
//        let calendar = Calendar.current
//        let currentYear = calendar.component(.year, from: Date())
//        guard let maximumDate = calendar.date(from: DateComponents(year: currentYear + 6))?.addingTimeInterval(-1) else {
//            return
//        }
//        self.txtStartDate.setupDatePicker(maximumDate: maximumDate, minimumDate: nil,dateFormat: "dd-MM-yyyy hh:mm a",selectedDate: startDate, pickerMode: .dateAndTime)
//
//        self.txtStartDate.textField.delegate = self
//
//    }
    func setData() {
        if let event = self.event {
            placeHolderImage.isHidden = true
            imgEventPhoto.setImage(url: event.coverImages?.first, placeholderColor: R.color.image_placeholder())
            txtTitle.text = event.eventName
            txtDescription.text = event.eventDescription
            txtCategory.text = event.eventCategory?.capitalized.replacingOccurrences(of: "_", with: " / ")
            category = event.eventCategory
            inviterName.text = event.inviterName
            txtDressCode.text = event.dressCode
            dressCode = event.dressCode
            
            
            if let s = event.startTime?.toDate {
                startDate = s
//                startDatePicker.date = s
                txtStartDate.text = s.stringValue(format: "dd-MM-yyyy hh:mm a")
            }
            
            let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
            
            self.eventType = e
            txtEventType.text  = e.name
            self.processLink(eventType: e.name)
            self.selectedLocation = self.event?.location
            
            if (self.eventType == .inPerson) {
                txtLocation.text = event.location?.locationName ?? "No address"
            } else {
                txtLocation.text = event.meetingLink ?? "No meeting link"
            }
            
            
            let p = EventPrivacy(rawValue: event.eventPrivacy ?? "") ?? .public
            self.eventPrivacy = p
            txtPrivacy.text = p.name
            
            anyoneCanInviteSwitch.isOn = event.anyoneCanInvite ?? false
            guestListVisibleSwitch.isOn = event.guestListVisible ?? false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.eventPhoto = self.imgEventPhoto.image ?? R.image.imagePlaceholder()
            }
            
            btnCreate.setTitle("Update", for: .normal)
            createOrUpdateNavTitle.text = "Update Event"
            
        }
    }
    @IBAction func actGuestListVisible(_ sender: UISwitch) {
        if sender.isOn == false && self.anyoneCanInviteSwitch.isOn {
            self.anyoneCanInviteSwitch.isOn = false
        }
    }
    
    @IBAction func actAnyOneInviteValueChanged(_ sender: UISwitch) {
        if sender.isOn && self.guestListVisibleSwitch.isOn == false {
            self.showAlert(title: "You need to enable allow guest list visibilty", description: "")
            sender.isOn = false
        }
    }
}

// MARK: Textfield delegate
extension CreateEventController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtTitle{
            let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
            clearTextButton.isHidden = expectedText.count == 0
           
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
 
 
    
}

// MARK: Actions
extension CreateEventController {
    @IBAction func didTapClearTitleButton(_ sender: UIButton) {
        txtTitle.text = ""
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCreateButton(_ sender: UIButton) {
        view.endEditing(true)
        let validated = validateWithErrorMessage()
        if validated {
            self.uploadEventPhoto()
        } else {
            sender.shake()
        }
    }
    
    @IBAction func didTapEventPhotoButton(_ sender: UIButton) {
        view.endEditing(true)
        ImagePicker.shared.openGalleryWithType(from: self, mediaType: Constants.imageMediaType) { [weak self] data in
            self?.eventPhoto = data.image
            self?.imgEventPhoto.image = data.image
            self?.placeHolderImage.isHidden = true
        }
    }
    
    @IBAction func didTapDressCodeButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let userEventFilter = ReusbaleOptionSelectionController(options: ["Casual", "Formal", "Business Formal dress code", "Semi-Formal Dress code", "Business Casual Dress code", "Casual dress code", "California Casual Dress code", "Black tie Dress code"], previouslySelectedOption: self.dressCode, screenName: "Dress Code", completion: { selected in
            self.dressCode = selected
            self.txtDressCode.text = selected
        })
        
        self.presentPanModal(userEventFilter)
    }
    
    @IBAction func didTapCategoryButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let userEventFilter = ReusbaleOptionSelectionController(options: EventCategories.allCases.map({$0.rawValue}), previouslySelectedOption: self.category?.capitalized, screenName: "Event Category", completion: { selected in
            
            let category = EventCategories(rawValue: selected)!
            self.category = category.serverValues
            self.txtCategory.text = category.rawValue
        })
        
        self.presentPanModal(userEventFilter)
    }
    @IBAction func didTapDatePicker(){
        let vc = DatePickerViewController()
        vc.selectedDate = startDate
        vc.changedate = { date in
            self.txtStartDate.text = date.stringValue(format: "EEE dd MMM yyyy, hh:mm a")
            self.startDate = date
        }
        self.presentPanModal(vc)

    }
    
    @IBAction func didTapPrivacyButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let userEventFilter = ReusbaleOptionSelectionController(options: [EventPrivacy.public.name,EventPrivacy.private.name], previouslySelectedOption: self.eventPrivacy?.name, screenName: "Privacy Event", completion: { selected in
            let eventPrivacy = EventPrivacy(name: selected) ?? .public
            self.txtPrivacy.text = eventPrivacy.name
            self.eventPrivacy = eventPrivacy
        })
        self.presentPanModal(userEventFilter)
    }
    
    @IBAction func didTapLocationButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let controller = SelectLocationController(title: "Select Location", selectedLocation: LocationModel.init(eventLocation: selectedLocation)) { location in
            self.selectedLocation = EventLocation(location: location)
            self.txtLocation.text = location.formattAdaddress
        }
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func didChangeStartDate() {
        view.endEditing(true)
//        startDate = startDatePicker.date
//        startDatePicker.minimumDate = Date()
//        txtStartDate.text = startDatePicker.date.ddMMyyyyhhmma()
    }

    @IBAction func didTapEventTypeButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let userEventFilter = ReusbaleOptionSelectionController(options: [EventType.inPerson.name, EventType.online.name], previouslySelectedOption: self.eventType?.name, screenName: "Event Type", completion: { selected in
            self.processLink(eventType: selected)
        })
        
        self.presentPanModal(userEventFilter)
    }
    
    func processLink(eventType:String) {
        if (eventType == EventType.inPerson.name) {
            self.eventType = .inPerson
            self.locationButton.isHidden = false
            self.locationOrWebURLTitleLbl.text = "Location"
            self.txtEventType.text = self.eventType?.name
            self.txtLocation.text = self.selectedLocation?.locationName ?? ""
            self.txtLocation.placeholder = "Select location"
        } else {
            self.eventType = .online
            self.locationButton.isHidden = true
            self.locationOrWebURLTitleLbl.text = "Meeting Link"
            self.txtEventType.text = self.eventType?.name
            self.txtLocation.text = self.event?.meetingLink ?? ""
            self.txtLocation.placeholder = "Enter meeting link"
            self.selectedLocation = nil
        }
    }
}

// MARK: Utility Methods
extension CreateEventController {
    
    func validate() -> Bool {
        var status = true
        if txtTitle.text.isTrimmedEmpty()
            || self.txtDescription.text.isTrimmedEmpty()
            || self.txtStartDate.text.isTrimmedEmpty()
            || self.inviterName.text.isTrimmedEmpty()
         //   || self.txtDressCode.text.isTrimmedEmpty()
          //  || self.txtCategory.text.isTrimmedEmpty()
            ||  self.txtEventType.text.isTrimmedEmpty()
            || self.txtLocation.text.isTrimmedEmpty()
            || self.txtPrivacy.text.isTrimmedEmpty() {
            status = false
        }
        return status
    }
    func validateWithErrorMessage() -> Bool {
        var status = true
        if txtTitle.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Title is missing")
            status = false
        }
        else if txtDescription.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Description is missing")
            status = false
        }
        else if txtStartDate.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Start date is missing")
            status = false
        }
        else if inviterName.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Invitor name is required")
            status = false
        }
        else if txtEventType.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Event type is required")
            status = false
        }
        else if txtLocation.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Location is missing")
            status = false
        }
        else if txtPrivacy.text.isTrimmedEmpty(){
            self.showErrorWith(message: "Privacy is missing")
            status = false
        }
        
        return status
    }
    //
}

// MARK: Web APIs
extension CreateEventController {
    
    private func uploadEventPhoto() {
        guard let img = eventPhoto , let media = Media(withImage: img, key: "images") else {
            self.createEvent()
            return
        }
      
        self.addBlurView(top: viewNavBar.bottom, bottom: 0, left: 0, right: 0)
        
        APIManager.fileUploader.uploadMedia(media: [media]) { progress in
            if self.progressBar.layer.presentation() != nil{
                self.progressBar.progress = Double(progress)
            }
        } completion: { response, error in
            self.viewProgressBar.isHidden = true
            self.removeBlurView()
            if let error = error {
                self.showErrorWith(message: error.message)
            } else {
                self.uploadUrl = response?.results?.first?.url
                self.createEvent()
            }
        }

    }
    
    private func createEvent() {
        let paramters = self.prepareParamters()
        btnCreate.startAnimation()
        self.handleViewLoading(enable: false)
        APIManager.social.createEvent(parameters: paramters, eventId: event?.eventID) { [weak self] response, error in
            guard let self = self else { return }
            self.btnCreate.stopAnimation()
            self.handleViewLoading(enable: true)
            if let error = error {
                self.showErrorWith(message: error.message)
            } else {
                self.handleEventSuccess(eventId: response?.id ?? "")
            }
        }
    }
    
    private func handleEventSuccess(eventId: String) {
        if self.event == nil {
            let controller = InviteFriendsToEventController(eventId: eventId)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    private func prepareParamters() -> [String:Any] {
        var parameters: [String: Any] = [
            "event_type": eventType?.rawValue ?? "in_person",
            "event_name": txtTitle.text ?? "",
            "description": txtDescription.text ?? "",
            "start_time": (startDate?.stringValue(format: "yyyy-MM-dd'T'HH:mm:ss") ?? "") + ".187Z",
            "event_privacy": eventPrivacy?.rawValue ?? "public",
            "event_inviter_name": inviterName.text ?? "",
            "anyone_can_invite": anyoneCanInviteSwitch.isOn,
            "guest_list_visible": guestListVisibleSwitch.isOn
        ]
        
        if eventPrivacy == .specificFriends {
            parameters["invited_users"] = selectedFriends.map({ $0.userID })
        } else if eventPrivacy == .specificGroup, let gId = selectedGroup?.groupID {
            parameters["group_id"] = gId
        }
        
        if let selectedCategory = category {
            parameters["event_category"] = selectedCategory
        }
        
        if let selectedDressCode = dressCode {
            parameters["dress_code"] = selectedDressCode
        }
        if let photoUrl = self.uploadUrl {
            parameters["cover_images_url"] = [photoUrl]
        }
        
        if (self.eventType == .inPerson) {
            if let location = selectedLocation {
                var locationParameter: [String: Any] = [:]
                locationParameter["country"] = location.country
                locationParameter["location_name"] = location.locationName
             //   locationParameter["place_name"] = location.placeName
                locationParameter["latitude"] = location.latitude
                locationParameter["longitude"] = location.longitude
                parameters["event_location"] = locationParameter
            }
        } else {
            parameters["meeting_link"] = self.txtLocation.text ?? ""
        }
        return parameters
    }
}

