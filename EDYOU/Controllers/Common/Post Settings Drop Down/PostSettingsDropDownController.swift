//
//  PostSettingsDropDownController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit
import PanModal

class PostSettingsDropDownController: BaseController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cstContainerViewBottom: NSLayoutConstraint!
    
    var completion: ((_ settings: PostSettings) -> Void)?
    
    var adapter: PostSettingsAdapter!
    var selectedSetting: PostSettings = .oneDay
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = PostSettingsAdapter(tableView: tableView, parent: self)
        adapter.selectedSetting = selectedSetting
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    init(selectedSetting: PostSettings, completion: @escaping (_ settings: PostSettings) -> Void) {
        super.init(nibName: PostSettingsDropDownController.name, bundle: nil)
        
        self.selectedSetting = selectedSetting
        self.completion = completion
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension PostSettingsDropDownController: PanModalPresentable {
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
        return .contentHeight(600)
    }
}
