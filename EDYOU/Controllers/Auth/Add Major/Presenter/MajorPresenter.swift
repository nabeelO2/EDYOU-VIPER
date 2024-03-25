//
//  MajorPresenter.swift
//  EDYOU
//
//  Created by imac3 on 22/03/2024.
//
import Foundation

protocol MajorPresenterProtocol: AnyObject {
    func viewDidLoad()
    func selectMajor()
    func setupUI()
    func validate()
    func getMajorSubjects()
    func setupDatePicker()
    func textFieldDidChangeSelection(text: String)
    func textFieldDidEndEditing(text: String)
    func saveGraduateInfo()
}

class MajorPresenter {
    weak var view: MajorViewProtocol?
    private let interactor: MajorInteractorProtocol
    private let router: AddMajorRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: MajorViewProtocol, router: AddMajorRouter, interactor : MajorInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension MajorPresenter: MajorPresenterProtocol {
    func selectMajor() {
        
    }
    
    func setupUI() {
        
    }
    
    func validate() {
        
    }
    
    func getMajorSubjects() {
        
    }
    
    func setupDatePicker() {
        
    }
    
    func textFieldDidChangeSelection(text: String) {
        
    }
    
    func textFieldDidEndEditing(text: String) {
        
    }
    
    func saveGraduateInfo() {
        
    }
    
    
    func navigateToSignup() {
        router.navigateToSignup()
    }
    
    func textFieldDidChange(text: String) {
        let isHidden = text.count == 0
        view?.passwordBtnVisibility(isHidden)
    }
    
    func navigateToForgetPassword() {
        
    }
    
    func showHidePassword() {
        view?.showHidePassword()
    }
    
    
    
    func login(email: String?, password: String?, isValidation: Bool) {
        if isValidation{
            //hit api
            view?.startAnimating()
            interactor.login(with: email!, password: password!)
        }else{
            view?.stopAnimating()
            view?.shakeLoginButton()
        }
    }
    
    
    func navigateToHome() {
    }
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    
}

extension MajorPresenter : MajorInteractorOutput{
    func error(error message: String) {
        view?.stopAnimating()
        view?.shakeLoginButton()
        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
        UserDefaults.standard.set(true, forKey: "loggedIn")
        //get user detail
    }
    func userInformation(response user: User) {
        view?.stopAnimating()
        
        if let id = user.userID, let pass  = Keychain.shared.accessToken {
            XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io" , pass: pass)
        }
        if user.major_start_year?.isEmpty == true || user.major_end_year?.isEmpty == true{
            UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
            UserDefaults.standard.synchronize()
            //move to add major Screen
            
//            let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
//            self.navigationController?.pushViewController(controller, animated: true)
//            return
        }
        
        let university = user.education.first ?? Education.nilProperties
        if user.name?.firstName?.isEmpty == false || user.name?.lastName?.isEmpty == false {
//            Application.shared.switchToHome()
//            move to home Screen
        } else {
//            move to name controller
            
//            let controller = AddNameController(university: university)
//            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}


protocol MajorViewProtocol: AnyObject {
    func prepareUI()
    func shakeLoginButton()
    func showHidePassword()
    func passwordBtnVisibility(_ isHidden : Bool)
    func showErrorMessage(_ message : String)
    func startAnimating()
    func stopAnimating()
}

