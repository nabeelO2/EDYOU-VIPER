//
//  ReusbaleOptionSelectionController.swift
//  EDYOU
//
//  Created by Aksa on 09/08/2022.
//

import UIKit
import PanModal

class ReusbaleOptionSelectionController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblScreenTitle: UILabel!
    
    let screenTitle: String?
    let previouslySelectedOption: String?
    let options: [String]?
    var optionshasIcons: Bool = false
    var completion: ((_ selected: String) -> Void)?
    var shouldShowPanWithoutBackground = false
    var dynamicContentHeight = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        tableView.estimatedRowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        
        lblScreenTitle.text = self.screenTitle ?? "Select Option"
    }
    
    init(options: [String]?, optionshasIcons: Bool = false, previouslySelectedOption: String?, screenName: String?, completion: @escaping (_ selected: String) -> Void,shouldShowPanWithoutBackground: Bool = false, dynamicContentHeight: Double = 0.0) {
        self.options = options
        self.previouslySelectedOption = previouslySelectedOption
        self.screenTitle = screenName ?? "Select Option"
        self.completion = completion
        self.dynamicContentHeight = dynamicContentHeight
        self.shouldShowPanWithoutBackground = shouldShowPanWithoutBackground
        self.optionshasIcons = optionshasIcons
        super.init(nibName: ReusbaleOptionSelectionController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.options = []
        self.previouslySelectedOption = nil
        self.screenTitle = nil
        super.init(coder: coder)
    }
    
    deinit {
        print("[ReusbaleOptionSelectionController] deinit")
    }
    
    func registerTableView() {
        self.tableView.register(ExperienceTypeTableViewCell.nib, forCellReuseIdentifier: ExperienceTypeTableViewCell.identifier)
    }
    
    @IBAction func closeButtonDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.completion?("")
    }
}

extension ReusbaleOptionSelectionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExperienceTypeTableViewCell.identifier, for: indexPath) as! ExperienceTypeTableViewCell
        let option = options?[indexPath.row] ?? ""
        cell.setData(option: option, checked: option == previouslySelectedOption, optionhasIcons: self.optionshasIcons)
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

extension ReusbaleOptionSelectionController: PanModalPresentable {
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
        if dynamicContentHeight != 0.0 {
            return .contentHeight(dynamicContentHeight)
        } else {
        return .contentHeight(250)
        }
            
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(500)
    }
    var panModalBackgroundColor: UIColor {
        if shouldShowPanWithoutBackground {
            return UIColor.clear
        } else {
        return UIColor(.black).withAlphaComponent(0.7)
        }
    }
}
