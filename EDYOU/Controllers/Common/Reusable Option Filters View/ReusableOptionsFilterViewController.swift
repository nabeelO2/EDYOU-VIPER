//
//  ReusableOptionsFilterViewController.swift
//  EDYOU
//
//  Created by Raees on 27/08/2022.
//

import UIKit
import PanModal
import EventKit

class ReusableOptionsFilterViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblScreenTitle: UILabel!
    
    let screenTitle: String?
    var layout: SearchType  = .posts
    var resultedOptions = [FilterOptions]()
    var completion: ((_ selected: [FilterOptions]) -> Void)?
    var viewModel : ReusableFiltersViewModel!
    var screenHeight = 0.0
    var institutes = [Institute]()
    var cities = [String]()
    var shouldAddShowResults = true
    @IBOutlet weak var topNavBar: UIView!
    var selectedIndexForDate = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        lblScreenTitle.text = self.screenTitle ?? "Select Option"
        tableView.reloadData()
    }
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    init(resultedOptions: [FilterOptions], layout: SearchType, previouslySelectedFilters: [FilterOptions] = [], screenName: String?, completion: @escaping (_ selectedFilters: [FilterOptions]) -> Void) {

        
        self.screenTitle = screenName ?? "Select Option"
        self.completion = completion
        self.layout = layout
        self.resultedOptions = resultedOptions
        if layout == .friendRequests {
            shouldAddShowResults = false
        }
        super.init(nibName: ReusableOptionsFilterViewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func registerTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(FilterReusableTableViewCell.nib, forCellReuseIdentifier: FilterReusableTableViewCell.identifier)
        self.tableView.register(FilterReusableShowResultsTableViewCell.nib, forCellReuseIdentifier: FilterReusableShowResultsTableViewCell.identifier)
    }
    func setupUI(){
        getInstitutes()
        getUSCities()
    }
    func getInstitutes() {
       let universities = Cache.shared.institutes
        if universities.count == 0 {
            APIManager.auth.getInstitutes { institutes, error in
                self.institutes = institutes
                if let e = error {
                    print(e.message)
                }
            }
        } else {
            self.institutes = universities
        }
        

    }
    func getUSCities() {
        self.cities = StaticData.shared.cities
    }
}
extension ReusableOptionsFilterViewController: UITableViewDelegate, UITableViewDataSource,FilterReusableProtocol {
    func textFieldStartEditing(_ starts: Bool) {
        if starts {
            panModalTransition(to: .longForm)
        } else {
            panModalTransition(to: .shortForm)
        }
    }
    
    func textFieldValueAdded(indexPathRox: Int, textFieldText: String) {
        self.resultedOptions[indexPathRox].valueChanged = true
        self.resultedOptions[indexPathRox].value = textFieldText
        self.tableView.reloadData()
        print(indexPathRox,textFieldText)
    }
    
    func dateValueAdded(indexPathRox: Int,date: String) {
        self.resultedOptions[indexPathRox].valueChanged = true
        self.resultedOptions[indexPathRox].value = date
            self.tableView.reloadData()
    }
    func switchValueChanged(indexPathRow: Int, value: Bool) {
        self.resultedOptions[indexPathRow].switchValue = value
        self.resultedOptions[indexPathRow].valueChanged = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldAddShowResults ? resultedOptions.count + 1 : resultedOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == resultedOptions.count && shouldAddShowResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterReusableShowResultsTableViewCell.identifier, for: indexPath) as! FilterReusableShowResultsTableViewCell
            cell.showResultsBtn.addTarget(self, action: #selector(showFiltersTapped(_:)), for: .touchUpInside)
            return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterReusableTableViewCell.identifier, for: indexPath) as! FilterReusableTableViewCell
            let option = resultedOptions[indexPath.row]
            cell.setData(option: option)
            cell.filtersDelegate = self
            if option.filterType == .boolean {
            cell.switchOption.tag = indexPath.row
            } else if option.filterType == .datePicker {
            cell.datePicker.tag = indexPath.row
            } else if option.filterType == .textField {
                cell.filterTextField.tag = indexPath.row
            } else if option.filterType == .none {
                cell.optionsView.isHidden = true
            }
            if option.valueChanged {
                if option.filterType == .boolean {
                    cell.switchOption.isOn = option.switchValue
                } else if option.filterType == .none {
                    cell.imgCheck.isHidden = false
                }else if option.filterType != .textField {
                    cell.optionsBtn.setImage(UIImage(named: "ic_cross_rounded_filled"), for: .normal)
                    cell.cancelBtn.isUserInteractionEnabled = true
                    cell.cancelBtn.tag = indexPath.row
                    cell.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped(_:)), for: .touchUpInside)
                }
                
            } else {
                cell.optionsBtn.setImage(UIImage(named: "Arrow-Gray"), for: .normal)
                cell.cancelBtn.isUserInteractionEnabled = false }
        return cell
        }
    }
    @objc func cancelBtnTapped(_ sender:UIButton) {
        resultedOptions[sender.tag].valueChanged = false
        resultedOptions[sender.tag].value = resultedOptions[sender.tag].defaultValue
        tableView.reloadData()
    }
    @objc func showFiltersTapped(_ sender:UIButton) {
       dismissWithCompletion()
    }
    func dismissWithCompletion() {
        self.dismiss(animated: true) {
            self.completion?(self.resultedOptions)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == resultedOptions.count {
        return UITableView.automaticDimension
        } else {
        return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= resultedOptions.count { return }
        var option = resultedOptions[indexPath.row]
        switch option.filterType
        {
        case .boolean:
            break
        case .dropdown:
            var subOptions = [String]()
            switch option.title {
            case "University":
                var universityNames = [String]()
                for i in institutes
                {
                    universityNames.append(i.name)
                }
                subOptions = universityNames
            case "Posts From":
                subOptions = ["Friends","People"]
            case "Categories":
                subOptions = ["Beauty", "Birthday", "Breakfast", "Drinks", "Hangout", "Lunch / Dinner", "Special Occasion", "Sport / Activities", "Work Meeting", "Other"]
            case "City":
                subOptions = self.cities
            default:
                break
            }
            let userEventFilter = ReusbaleOptionSelectionController(options: subOptions, previouslySelectedOption: option.value, screenName: option.title,completion: { selected in
                option.value = selected
                option.valueChanged = true
                self.resultedOptions[indexPath.row] = option
                self.tableView.reloadData()
            }, shouldShowPanWithoutBackground: true , dynamicContentHeight: self.screenHeight)
            self.presentPanModal(userEventFilter)
        case .textField:
            break
        case .datePicker:
            break
        case .none:
            viewModel = ReusableFiltersViewModel()
            self.resultedOptions = viewModel.getResultedOptions(layout: .friendRequests)
            if option.valueChanged {
                option.valueChanged = false
            } else {
                option.valueChanged = true
            }
            self.resultedOptions[indexPath.row] = option
            dismissWithCompletion()
            break
        }
        
    }
}
extension ReusableOptionsFilterViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tableView
    }
    var showDragIndicator: Bool {
        return false
    }
    var shouldRoundTopCorners: Bool {
        if layout == .friendRequests || layout == .friendsSort {
        return true
        } else {
            return false
        }
    }
    var shortFormHeight: PanModalHeight {
        switch layout {
        case .posts:
            screenHeight = 330
        case .people:
            screenHeight = 292
        case .groups:
            screenHeight = 248
        case .events:
            screenHeight = 424
        case .friends:
            screenHeight = 292
        case .friendRequests:
            screenHeight = 156
        case .friendsSort:
            screenHeight = 248
//        case .trending:
//            break
        }
        return .contentHeight(screenHeight)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }
}

