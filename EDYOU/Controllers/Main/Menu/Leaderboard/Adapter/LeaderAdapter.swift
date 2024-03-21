//
//  LeaderAdapter.swift
//  EDYOU
//
//  Created by imac3 on 13/09/2023.
//

import Foundation
import PanModal
import UIKit
import EmptyDataSet_Swift
import AVKit

class LeaderAdapter: NSObject {
    
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var parent: LeaderboardController? {
        return tableView.viewContainingController() as? LeaderboardController
    }
    
    var isLoading = true
    
    //var topLeaders = [Leader]()
    
    var leaders = [Leader](){
        didSet{
            leaders = leaders.sorted(by: {($0.rank ?? 0) < ($1.rank ?? 0)})
        }
    }
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        
        tableView.register(LeaderboardTabCell.nib, forCellReuseIdentifier: LeaderboardTabCell.identifier)
        tableView.register(TopLeadersCell.nib, forCellReuseIdentifier: TopLeadersCell.identifier)
        tableView.register(RankHeaderCell.nib, forCellReuseIdentifier: RankHeaderCell.identifier)
        tableView.register(RankCell.nib, forCellReuseIdentifier: RankCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
//        self.tableView.emptyDataSetSource = self
//        self.tableView.emptyDataSetDelegate = self
    }
    
    @objc func topLeaderAction(_ sender : UIButton){
       
        
//            if let user = topLeaders.object(at: sender.tag)?.user {
//
//                let controller = ProfileController(user: user)
//                let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
//                navC?.pushViewController(controller, animated: true)
//
//            }
    }
}



// MARK: - TableView DataSource & Delegate
extension LeaderAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        }
        
        return  leaders.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         
         if indexPath.row == 0{
            return 64
        }
        else if indexPath.row == 1{
//                return 260//leader
            return UITableView.automaticDimension
        }
        else{
            return 128//rank
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isLoading {
            if indexPath.row != 0{
                if let cell = cell as? RankCell{
                    cell.emptyUserInfo()
                    cell.beginSkeltonAnimation()
                }
                
               
            }
            else{
                
                if let cell = cell as? TopLeadersCell{
//                    cell.bgView.isHidden = true
                 
                    cell.beginSkeltonAnimation()
                }
               
               
            }
        }
        else{
            if indexPath.row == 0 {
                
                if let cell = cell as? TopLeadersCell{
//                    cell.emptyUserInfo()
                    cell.endSkeltonAnimation()
                }
            }
           
            else{
                
                if let cell = cell as? RankCell{
//                    cell.emptyUserInfo()
                    cell.endSkeltonAnimation()
                }
                
            }
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if isLoading {
            if indexPath.row == 0{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTabCell.identifier, for: indexPath) as? LeaderboardTabCell else { return UITableViewCell()}
                    cell.beginSkeltonAnimation()
                  
                return cell
                
                
            }
            else if indexPath.row == 1{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TopLeadersCell.identifier, for: indexPath) as? TopLeadersCell else { return UITableViewCell()}
                    
                    cell.beginSkeltonAnimation()
                    return cell
                
                
                
            }
            else{
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.identifier, for: indexPath) as? RankCell else { return UITableViewCell()}
                    //                    cell.bgView.isHidden = true
                    cell.bgV.layer.cornerRadius = 8
//                        cell.bgV.layer.borderWidth = 1.0
                    cell.topSepratorV.isHidden = true//indexPath.row != 2
                    cell.beginSkeltonAnimation()
                    return cell
                
            }
        }
        
        else{
            if indexPath.row == 0{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTabCell.identifier, for: indexPath) as! LeaderboardTabCell
                cell.selectedTab(parent?.typeFilter ?? .friends)
                cell.tabChange = { tag in
                   
                    switch tag {
                    case 0:
                        print("Friends")
//                        self.showFriendsDropDown()
                        self.parent?.getLeader(type: .friends,reload: true)
                        break
                    case 1:
                        print("School")
                        self.parent?.getLeader(type: .school,reload: true)
                        break
                    case 2:
                        print("Today")
                        self.showDropDown()
                        break
                    case 3:
                        print("national")
                       // self.showDropDown()
                        self.parent?.getLeader(type: .national,reload: true)
                        break
                    default:
                        break
                    }
                }
                let filter = parent?.leaderFilterBy.getValue() ?? ""
//                cell.tabLabels[2].text = filter.capitalized
                
                cell.tabLabels[0].text = filter.capitalized
                cell.endSkeltonAnimation()
                return cell
                //                cell.bgView.isHidden = false
            }
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: TopLeadersCell.identifier, for: indexPath) as! TopLeadersCell
//                cell.bgView.isHidden = false
//                cell.user1Btn.tag = 1
//                cell.user2Btn.tag = 0
//                cell.user3Btn.tag = 2
//                cell.user1Btn.addTarget(self, action: #selector(topLeaderAction(_:)), for: .touchUpInside)
//                cell.user2Btn.addTarget(self, action: #selector(topLeaderAction(_:)), for: .touchUpInside)
//                cell.user3Btn.addTarget(self, action: #selector(topLeaderAction(_:)), for: .touchUpInside)
                let filter = parent?.leaderFilterBy ?? .all
                cell.setupData(leaders[indexPath.row],selectedFilter: filter)
            
                cell.endSkeltonAnimation()
//                cell.tabChange = { filter in
////                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
//                        self.parent?.leaderFilterBy = filter
////                    }
//
//                }
//                cell.tabChange = { filter in
//                    self.showDropDown()
//                }

                return cell
            }
           
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.identifier, for: indexPath) as! RankCell
                
                    cell.setupData(leaders[indexPath.row])
                
                cell.bgV.layer.cornerRadius = 8
//                cell.topSepratorV.isHidden = indexPath.row != 1
                cell.endSkeltonAnimation()
                return cell
            }
            
        }
        
        
        
        
         
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
        }
        else{
            if let user = leaders.object(at: indexPath.row)?.user {
                
                let controller = ProfileController(user: user)
                let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                navC?.pushViewController(controller, animated: true)
                
            }
        }
    
    }
    
     
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isLoading {
            if indexPath.row != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.identifier, for: indexPath) as! RankCell
                cell.topSepratorV.isHidden = indexPath.row != 1
                cell.endSkeltonAnimation()
                
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: TopLeadersCell.identifier, for: indexPath) as! TopLeadersCell
//                cell.bgView.isHidden = true
                cell.endSkeltonAnimation()
            }
        }
       
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    private func showFriendsDropDown(){
        let options = ["Friends", "National", "School"]
        let previousSelectedOption = parent?.typeFilter.rawValue.capitalized
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "", completion: { selected in
            if (selected.contains("Friends")) {
               
                self.parent?.getLeader(type: .friends,reload: true)
               
            } else if (selected.contains("National")) {
                
                self.parent?.getLeader(type: .national,reload: true)
            }
            else if (selected.contains("School")) {
                
                self.parent?.getLeader(type: .school,reload: true)
            }
           
        })
        self.parent?.presentPanModal(userEventFilter)
    }
    
    private func showDropDown(){
        let options = ["Today", "Weekly","Monthly","Yearly"]
        let previousSelectedOption = parent?.leaderFilterBy.getValue().capitalized
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "", completion: { selected in
            if (selected.contains("Today")) {
                self.parent?.leaderFilterBy = .daily
               
               
            } else if (selected.contains("Weekly")) {
                self.parent?.leaderFilterBy = .weekly
                
            }else if (selected.contains("Monthly")) {
                self.parent?.leaderFilterBy = .monthly
               
            }else if (selected.contains("Yearly")) {
                self.parent?.leaderFilterBy = .yearly
                
            }
           
        })
        self.parent?.presentPanModal(userEventFilter)
    }
    
    private func getFilterType(_ tag : Int)->String{
        switch tag {
        case 0:
            return "Friends"
            
        case 2:
            return "National"
            
        default:
            return "School"
            
        }
    }
}
