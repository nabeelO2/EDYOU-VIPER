//
//  InviteFriendsPresenter.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//
import Foundation

protocol InviteFriendsPresenterProtocol: AnyObject {//Input
    func viewDidLoad()
    func addFriend(_ user : User, _ onSuccess: @escaping (Any) -> Void)
    func navigateToAddPhotoVC()
}

class InviteFriendsPresenter {
    weak var view: InviteFriendsViewProtocol?
    private let interactor: InviteFriendsInteractorProtocol
    private let router: InviteFriendsRouter

    
    init(view: InviteFriendsViewProtocol, router: InviteFriendsRouter, interactor : InviteFriendsInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}

extension InviteFriendsPresenter: InviteFriendsPresenterProtocol {
    
    func addFriend(_ user: User, _ onSuccess: @escaping (Any) -> Void) {
        interactor.addFriend(user, onSuccess)
    }
    
        
    func viewDidLoad() {
        view?.prepareUI()
        interactor.getSuggestedPeople(.peoples)
    }
    
    func navigateToAddPhotoVC() {
        router.navigateToAddPhotoVC()
    }
    
}

extension InviteFriendsPresenter : InviteFriendsInteractorOutput{
    func suggestedPeoples(_ users: [User]?) {
        view?.reloadTableView(users ?? [])
    }
    
    func error(error message: String) {
        view?.showError(message)
    }
    
    func updateNextButtonUI() {
        view?.updateUI()
    }
    
}

protocol InviteFriendsViewProtocol: AnyObject {//Output
    func prepareUI()
    func showError(_ error : String)
    func reloadTableView(_ peoples : [User])
    func updateUI()
}
