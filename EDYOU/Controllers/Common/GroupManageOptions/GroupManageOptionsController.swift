//
//  GroupManageOptionsController.swift
//  EDYOU
//
//  Created by Aksa on 07/09/2022.
//

import UIKit
import PanModal

class GroupManageOptionsController: BaseController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblScreenTitle: UILabel!
    
    let screenTitle: String?
    let optionImages: [String]?
    let options: [String]?
    var completion: ((_ selected: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        tableView.estimatedRowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        lblScreenTitle.text = self.screenTitle ?? ""
    }
    
    init(options: [String]?, optionImages: [String]?, screenName: String?, completion: @escaping (_ selected: String) -> Void) {
        self.options = options
        self.optionImages = optionImages
        self.screenTitle = screenName ?? "Select Option"
        self.completion = completion
        super.init(nibName: GroupManageOptionsController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.options = []
        self.optionImages = []
        self.screenTitle = nil
        super.init(coder: coder)
    }
    
    deinit {
        print("[ReusbaleOptionSelectionController] deinit")
    }
    
    func registerTableView() {
        self.tableView.register(PostPrivacyCell.nib, forCellReuseIdentifier: PostPrivacyCell.identifier)
    }
    
    @IBAction func closeButtonDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GroupManageOptionsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostPrivacyCell.identifier, for: indexPath) as! PostPrivacyCell
        let option = options?[indexPath.row] ?? ""
        
        cell.imgCheckMark.isHidden = true
        cell.lblSetting.text = option
        
        if let imgName = optionImages?[indexPath.row] {
            cell.imgIcon.image = UIImage(named: imgName)
        } else {
            cell.imgIcon.image = UIImage(named: "edit-group")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options?[indexPath.row] ?? ""
        
        self.dismiss(animated: true) {
            self.completion?(option)
        }
    }
}

extension GroupManageOptionsController: PanModalPresentable {
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
        return .contentHeight(250)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
}
