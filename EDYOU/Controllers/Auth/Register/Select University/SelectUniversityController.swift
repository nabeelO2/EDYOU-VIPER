//
//  SelectUniversityController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

class SelectUniversityController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtUniversity: BorderedTextField!
    @IBOutlet weak var btnNext: UIButton!
    var universities: [DataPickerItem<Institute>] = []
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getInstitutes()
    }

}



// MARK: - Actions
extension SelectUniversityController {
    @IBAction func didTapSignInButton(_ sender: Any) {
        for controller in (navigationController?.viewControllers ?? []) {
            if controller is LoginController {
                navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
    }
    @IBAction func didTapUniversityDropDownButton(_ sender: Any) {
        
        
        let controller = DataPickerController(title: "Your University", data: universities, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.txtUniversity.text = selectedItem.title
        }
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        
        let validated  = validate()
        if validated {
            let item = universities.first { $0.isSelected == true }
            guard let institute = item?.data else { return }
            let controller = AddEmailController(institute: institute)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            btnNext.shake()
        }
        
    }
}

// MARK: - Utility Methods
extension SelectUniversityController {
    func setupUI() {
        txtUniversity.validations = [.required]
    }
    func validate() -> Bool {
        let emailValidated = txtUniversity.validate()
        return emailValidated
    }
}

// MARK: - Web APIs
extension SelectUniversityController {
    func getInstitutes() {
        universities = Cache.shared.institutes.dataPickerItems()
        
        if universities.count == 0 {
            txtUniversity.startLoading()
            txtUniversity.isUserInteractionEnabled = false
        }
        APIManager.auth.getInstitutes { institutes, error in
            self.txtUniversity.stopLoading()
            self.txtUniversity.isUserInteractionEnabled = false
            
            if let e = error {
                self.showErrorWith(message: e.message)
            } else {
                self.universities = institutes.dataPickerItems()
            }
            
        }
    }
}
