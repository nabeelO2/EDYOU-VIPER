//
//  PostPrivacyDropDownController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit
import PanModal

protocol PostPrivacyDropDownProtocol {
    func friendPrivacy(_ settings: PostPrivacy, _ friends: [User])
    func groupSelected(group: Group?)
}

class PostPrivacyDropDownController: BaseController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cstContainerViewBottom: NSLayoutConstraint!
    
//    var completion: ((_ settings: PostPrivacy, _ friends: [User]) -> Void)?
    var delegate: PostPrivacyDropDownProtocol!
    
    var adapter: PostPrivacyAdapter!
    var selectedSetting: PostPrivacy = .public
    

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = PostPrivacyAdapter(tableView: tableView)
        adapter.selectedSetting = selectedSetting
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    init(selectedPrivacy: PostPrivacy, delegate: PostPrivacyDropDownProtocol) {
        super.init(nibName: PostPrivacyDropDownController.name, bundle: nil)
        self.selectedSetting = selectedPrivacy
        self.delegate = delegate
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension PostPrivacyDropDownController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(450)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(550)
    }
}
