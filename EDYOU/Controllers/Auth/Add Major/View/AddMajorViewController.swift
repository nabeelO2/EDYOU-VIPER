//
//  InviteFriendsViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit
import TransitionButton
class AddMajorViewController: BaseController {
    
    @IBOutlet weak var nextButton: TransitionButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!

    var majors: [DataPickerItem<Any>] = []

    @IBOutlet weak var majorTextField: BorderedTextField!
    @IBOutlet weak var majorStartDate: BorderedTextField!
    @IBOutlet weak var majorEndDate: BorderedTextField!
    
    
    
    var startDate: Date?
    var endDate: Date?
    var presenter : MajorPresenterProtocol!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getMajorSubjects()
        setupUI()
        setupDatePicker()
//        nextButton.alpha = 0.5
//        nextButton.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.
    }
    
//    func updateUI()
//    {
//        nextButton.alpha = 1.0
//        nextButton.isUserInteractionEnabled = true
//    }
    
    @IBAction func selectMajor(_ sender: UIButton) {
        let controller = DataPickerController(title: "Choose Major", data: self.majors, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.majorTextField.text = selectedItem.title
//            if (self.validate()) {
//                self.updateUI()
//            }
        }
        controller.showFullScreen = true
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        if validate() {
            saveGraduateInfo()
        }
       
    }
  
}

extension AddMajorViewController {
    
    func setupUI() {
        majorTextField.validations = [.required]
        majorStartDate.validations = [.required]
        majorEndDate.validations = [.required]
        if  let uniName = UserDefaults.standard.value(forKey: "SelectedUni") {
            self.headerLabel.text = self.headerLabel.text! +  " \(uniName)"
        }
      
    }
    
    
    func validate() -> Bool {
        let majorValidated = majorTextField.validate()
        let majarStartDateValidated = majorStartDate.validate()
        let majarEndDateValidated = majorEndDate.validate()
        return majorValidated && majarStartDateValidated && majarEndDateValidated
    }
    
    func setupDatePicker() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        guard let maximumDate = calendar.date(from: DateComponents(year: currentYear + 6))?.addingTimeInterval(-1) else {
            return
        }
        self.majorStartDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: nil)
        self.majorEndDate.setupDatePicker(maximumDate: maximumDate, minimumDate: nil, selectedDate: nil)
        self.majorStartDate.textField.delegate = self
        self.majorEndDate.textField.delegate = self
    }
    
}

extension AddMajorViewController: UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if ( textField == majorEndDate.textField) {
            self.checkTxtFieldValidation()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ( textField == majorEndDate.textField) {
            self.checkTxtFieldValidation()
//            if (validate()) {
//                updateUI()
//            }
        }
    }
 
 
    func checkTxtFieldValidation() {
        guard let startTxtDate = self.majorStartDate.text else {
            return
        }
        guard  let endTxtDate = self.majorEndDate.text else {
            return
        }

        guard let startDate = startTxtDate.toDate else {
            return
        }
        guard  let endDate = endTxtDate.toDate else {
            return
        }

        let isGreater = startDate.isGreaterThan(endDate)
        let isEqual = startDate.isEqualTo(endDate)
        if (isGreater || isEqual) {
            self.majorEndDate.text = nil
            self.showAlert(title: "Invalid Date", description: "End Date should be greater than start date")
        }
    }
    
}

// API Call
extension AddMajorViewController {
    
    func getMajorSubjects() {
        majorTextField.startLoading()
        majorTextField.isUserInteractionEnabled = false
        APIManager.auth.getMajorSubjects { (subjects, error) in
            if error == nil {
                
                self.majorTextField.stopLoading()
                self.majorTextField.isUserInteractionEnabled = false
                self.majors = DataPickerItem<Any>.from(strings: subjects.sorted())
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func saveGraduateInfo()
    {
        nextButton.startAnimation()
        let params = [
            "major": String(format:"%@",majorTextField.text!),
            "major_start_year": String(format:"%@",(self.majorStartDate.selectedDate?.toUTC())!),
            "major_end_year": String(format:"%@",(self.majorEndDate.selectedDate?.toUTC())!),
            
//            "school_id": String(format:"%@",selectedUniversityID),
//            "state": String(format:"%@",selectedState)
        ] as [String : Any]
        APIManager.auth.saveGraduteInfo(parameters: params) { [weak self] response, error in
            guard let self = self else { return }
            self.nextButton.stopAnimation()
            UserDefaults.standard.removeObject(forKey: "isUserAddedMajor")
            UserDefaults.standard.synchronize()

            if error == nil {
                let controller = InviteFriendViewController()
                if navigationController == nil {
                    let nav = UINavigationController(rootViewController: controller)
                    nav.setNavigationBarHidden(true, animated: false)
                    self.present(nav, presentationStyle: .fullScreen)
                }
                else{
                    navigationController?.pushViewController(controller, animated: true)
                }
                let nav = navigationController == nil ? UINavigationController() : navigationController
                
            } else {
                self.showErrorWith(message: error?.message ?? "Invalid response")
            }
            
        }
    }
}


extension AddMajorViewController : MajorPresenterProtocol{
    func selectMajor() {
        
    }
    
    func validate() {
        
    }
    
    func textFieldDidChangeSelection(text: String) {
        
    }
    
    func textFieldDidEndEditing(text: String) {
        
    }
    
    
}

extension AddMajorViewController : MajorViewProtocol{
    func prepareUI() {
        
    }
    func shakeLoginButton(){
        
    }
    func showHidePassword(){
        
    }
    func passwordBtnVisibility(_ isHidden : Bool){
        
    }
    func showErrorMessage(_ message : String){
        
    }
    func startAnimating(){
        
    }
    func stopAnimating(){
        
    }
}
