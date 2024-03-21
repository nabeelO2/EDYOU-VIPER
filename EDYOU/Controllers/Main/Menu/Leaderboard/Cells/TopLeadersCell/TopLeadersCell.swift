//
//  TopLeadersCell.swift
//  EDYOU
//
//  Created by imac3 on 12/09/2023.
//

import UIKit

class TopLeadersCell: UITableViewCell {

    @IBOutlet weak var name3Lbl : UILabel!
    @IBOutlet weak var name1Lbl : UILabel!
    @IBOutlet weak var institute1Lbl : UILabel!
    @IBOutlet weak var points1Lbl : UILabel!
    @IBOutlet weak var user1ProfileImg : UIImageView!
    @IBOutlet weak var user2ProfileImg : UIImageView!
    @IBOutlet weak var user3ProfileImg : UIImageView!
    @IBOutlet weak var institute2Lbl : UILabel!
    @IBOutlet weak var name2Lbl : UILabel!
    @IBOutlet weak var institute3Lbl : UILabel!
    @IBOutlet weak var points3Lbl : UILabel!
    @IBOutlet weak var points2Lbl : UILabel!
    @IBOutlet weak var user1BGImg : UIImageView!
    @IBOutlet weak var filterSegment : UISegmentedControl!
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var user1Btn : UIButton!
    @IBOutlet weak var user2Btn : UIButton!
    @IBOutlet weak var user3Btn : UIButton!
    
    @IBOutlet weak var user1CrownImg : UIImageView!
    @IBOutlet weak var user2CrownImg : UIImageView!
    @IBOutlet weak var user3CrownImg : UIImageView!
    
    
    var tabChange : ((LeaderBoardPeriodFilter)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(_ leaders : Leader, selectedFilter : LeaderBoardPeriodFilter = .daily) {
//        emptyAllRanksUser()
//        switch leaders.count {
//        case 1:
            setupRank1User(leaders)
//            break
//        case 2:
//            setupRank1User(leaders[0])
//            setupRank2User(leaders[1])
//            break
//        case 3:
//            setupRank1User(leaders[0])
//            setupRank2User(leaders[1])
//            setupRank3User(leaders[2])
//            break
//        default:
//            return
//        }
        
        
//        switch selectedFilter {
//        case .all:
//            filterSegment.selectedSegmentIndex = 0
//        case .weekly:
//            filterSegment.selectedSegmentIndex = 1
//        case .daily:
//            filterSegment.selectedSegmentIndex = 0
//        case .monthly:
//            filterSegment.selectedSegmentIndex = 2
//        case .yearly:
//            filterSegment.selectedSegmentIndex = 3
//        }
        
        
    }
    
    private func setupRank1User(_ leader : Leader){
        if leader.user == nil {
            return
        }
        user1ProfileImg.setImage(url: leader.user?.profileImage, placeholder: R.image.profile_image_dummy())
        name1Lbl.text = leader.user?.name?.completeName ?? leader.user?.name?.firstName
        institute1Lbl.text = leader.user?.college
        points1Lbl.text = "\(leader.score ?? 0) Points"
        user1CrownImg.image = UIImage(named: "Crown1")
        user1ProfileImg.isHidden = false
        user1CrownImg.isHidden = false
    }
    
    private func setupRank2User(_ leader : Leader){
        if leader.user == nil {
            return
        }
        user2ProfileImg.setImage(url: leader.user?.profileImage, placeholder: R.image.profile_image_dummy())
        name2Lbl.text = leader.user?.name?.completeName ?? leader.user?.name?.firstName
        institute2Lbl.text = leader.user?.college
        points2Lbl.text = "\(leader.score ?? 0)"
        user2ProfileImg.isHidden = false
        user2CrownImg.isHidden = false
        user2CrownImg.image = UIImage(named: "Crown2")
    }
    private func setupRank3User(_ leader : Leader){
        if leader.user == nil {
            return
        }
        user3ProfileImg.setImage(url: leader.user?.profileImage, placeholder: R.image.profile_image_dummy())
        name3Lbl.text = leader.user?.name?.completeName ?? leader.user?.name?.firstName
        institute3Lbl.text = leader.user?.college
        points3Lbl.text = "\(leader.score ?? 0)"
        user3ProfileImg.isHidden = false
        user3CrownImg.isHidden = false
        user3CrownImg.image = UIImage(named: "Crown3")
    }
    
    private func emptyAllRanksUser(){
        user1ProfileImg.image = nil
        name1Lbl.text = ""
        institute1Lbl.text = ""
        points1Lbl.text = ""
        
        user2ProfileImg.image = nil
        name2Lbl.text = ""
        institute2Lbl.text = ""
        points2Lbl.text = ""
        
        user3ProfileImg.image = nil
        name3Lbl.text = ""
        institute3Lbl.text = ""
        points3Lbl.text = ""
        
        user1ProfileImg.isHidden = true
        user2ProfileImg.isHidden = true
        user3ProfileImg.isHidden = true
        
        user1CrownImg.isHidden = true
        user2CrownImg.isHidden = true
        user3CrownImg.isHidden = true
    }
    
    
    func beginSkeltonAnimation() {
        
        layoutIfNeeded()
//        filterSegment.isHidden = true
        let views: [UIView] = [name3Lbl, name1Lbl,name2Lbl ,institute1Lbl, institute2Lbl, institute3Lbl, points1Lbl, points2Lbl, points3Lbl,bgView]
        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
//        filterSegment.isHidden = false
        let views: [UIView] = [name3Lbl, name1Lbl,name2Lbl ,institute1Lbl, institute2Lbl, institute3Lbl, points1Lbl, points2Lbl, points3Lbl, bgView]
        views.forEach { $0.stopSkelting() }
    }
    
    
    @IBAction func filterSegment(_ sender : UISegmentedControl){
         let tag = sender.selectedSegmentIndex
        switch tag {
        case 1:
            tabChange?(.weekly)
            break
        case 2:
            tabChange?(.monthly)
            break
        case 3:
            tabChange?(.yearly)
            break
        default:
            tabChange?(.daily)
            break
        }
    }

}
