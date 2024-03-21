//
//  LeaderboardViewController.swift
//  EDYOU
//
//  Created by imac3 on 13/09/2023.
//

import UIKit
import PanModal

class LeaderboardController: BaseController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet var tabSeperators: [UIView]!
    @IBOutlet var tabBtn: [UIButton]!
    @IBOutlet var tabSegment: UISegmentedControl!
    @IBOutlet var emptyStack : UIStackView!
    // MARK - Properties
    var adapter: LeaderAdapter!
    var loading = false
    var leaderResult : LeaderFilter?{
        didSet{
            filterLeader()
        }
    }
    var leaderFilterBy : LeaderBoardPeriodFilter = .yearly{
        didSet{
            getLeader(type: typeFilter,reload: true)
        }
    }
    var typeFilter : LeaderBoardTypeFilter = .national
    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = LeaderAdapter(tableView: tableView)
        getLeader(type: typeFilter,reload: true)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
//        didTapTabButton(tabBtn[0])
    }

    @IBAction func didTapTabButton(_ sender: UIButton) {
        
//        tabLabels.forEach { $0.textColor = R.color.sub_title() }
//
//        tabSeperators.forEach{ $0.isHidden = true }
//        tabLabels.first { $0.tag == sender.tag }?.textColor = R.color.buttons_green()
//
//        let sepView = tabSeperators.first { $0.tag == sender.tag }
//        sepView?.isHidden = false
//
//        getLeader(type: <#T##LeaderBoardTypeFilter#>, reload: true)
    }
    
    @IBAction func changeSegmentController(_ sender : UISegmentedControl){
//        getLeader(tag: sender.selectedSegmentIndex, reload: true)
    }
    @IBAction func didTapFilterAction(){
        
//            var sheetOptions: [String]?
//            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
//            let indexPath = IndexPath(row: 0, section: 0) // assuming cell is for first or only section of table view
//            
//                sheetOptions = ["Daily","Weekly","Monthly","Yearly"]
//            
//            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            showActionSheetWithoutPost(sheetOptions: sheetOptions!)
        
    }
    
    func showActionSheetWithoutPost( sheetOptions:[String]) {
       
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "", screenName: "", completion: { selected in
            //self.selectedGender = selected
            // self.genderTextfield.text = selected
            var reportContentObject = ReportContent()
//            reportContentObject.userID = self.user?.userID
            reportContentObject.userName = ""//self.user?.name?.completeName
            self.sheetButtonActionsWithoutPost(selectedOption: selected, reportContentObject: reportContentObject)
        })
        
        self.presentPanModal(genericPicker)
    }
    func sheetButtonActionsWithoutPost(selectedOption: String, reportContentObject: ReportContent ) {
       // guard posts.object(at: indexPath.row) != nil else { return }

        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            break
        case "UnFollow":
           break
        case "Edit Profile":
            goBack()
        case "Block":
//            blockUser()
            goBack()
        case "Report":
//            moveToReportContentScreen(reportContentObject: reportContentObject)
            goBack()
        case "Delete":
           break
        default:
            print("")

        }
    }
    
    func reloadTableViewWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.tableView.reloadData()
//            self.tableView.beginUpdates()
//            self.tableView.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
//            self.tableView.endUpdates()
        }
    }
    
    

    func emptyAdapterList(){
        adapter.leaders.removeAll()
        
        tableView.reloadData()
    }
}


// MARK: - Web APIs
extension LeaderboardController {
    
    func getLeader(type : LeaderBoardTypeFilter = .national,reload: Bool = true) {
//        emptyAdapterList()
        typeFilter = type
        loading = true
        self.adapter.isLoading = true
        emptyAdapterList()
        
        APIManager.social.getLeaderwithFilter(type: type,filter: leaderFilterBy) {[weak self] leader, error in
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            self.loading = false
            
            if error == nil {
                if reload {
                    self.leaderResult = leader
                }
                else {
                    
                }
                
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
    }
    private func filteredLeaders()->[Leader]{
        switch leaderFilterBy {
        case .all:
            return  leaderResult?.all_time as? [Leader] ?? []
        case .weekly:
            return  leaderResult?.weekly as? [Leader] ?? []
        case .daily:
            return  leaderResult?.daily as? [Leader] ?? []
        case .monthly:
            return  leaderResult?.monthly as? [Leader] ?? []
        case .yearly:
            return  leaderResult?.yearly as? [Leader] ?? []
        }

    }
    
    private func filterLeader(){
        let leaders = filteredLeaders().filter({ obj in
            obj.user != nil
        })
           
        let topLeaders = leaders.sorted(by: {$0.rank! < $1.rank!})
             
            var leadersFilter = topLeaders
        emptyStack.isHidden = !(topLeaders.count == 0)
//            if topLeaders.count == 3 {
//                leadersFilter.removeFirst()
//                leadersFilter.removeFirst()
//                leadersFilter.removeFirst()
//            }
//            if topLeaders.count == 2 {
//                leadersFilter.removeFirst()
//                leadersFilter.removeFirst()
//            }
//            if topLeaders.count == 1 {
//                leadersFilter.removeFirst()
//            }
            
            
//            if topLeaders.count > 2 {
//                self.adapter.topLeaders = [topLeaders[0],topLeaders[1],topLeaders[2]]
//                self.adapter.leaders = leadersFilter
//
//
//            }
//            else{
//                self.adapter.topLeaders = topLeaders
                
                self.adapter.leaders = leadersFilter
                
//            }
            
            let dummy = Leader(rank: 0, score: 0)

            self.adapter.leaders.insert(dummy, at: 0)
            
            self.reloadTableViewWithDelay()
            
//        }
        
    }
}

