//
//  LeaderboardTabCell.swift
//  EDYOU
//
//  Created by imac3 on 12/09/2023.
//

import UIKit

class LeaderboardTabCell: UITableViewCell {

    
    @IBOutlet var tabBGV: [UIView]!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet var tabSeperators: [UIView]!
    @IBOutlet var tabSegment: UISegmentedControl!
    
    var tabChange : ((Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapTabButton(_ sender : UIButton){
        print(sender.tag)
        
        
        tabLabels.forEach { $0.textColor = R.color.sub_title() }
        
        tabSeperators.forEach{ $0.isHidden = true }
        tabLabels.first { $0.tag == sender.tag }?.textColor = R.color.buttons_green()
       
        let sepView = tabSeperators.first { $0.tag == sender.tag }
        sepView?.isHidden = false
        
        if let change = tabChange {
            change(sender.tag)
        }
       
        
    }
    
    @IBAction func didTapButton(_ sender : UIButton){
        print(sender.tag)
        //0 for friends
        //1 for school
        //2 for today
        //3 for national
        
       unSelectAllView()
        selectedTab(with: sender.tag)
        
        
        if let change = tabChange {
            change(sender.tag)
        }
       
        
    }
    
    func unSelectAllView(){
        tabBGV.forEach { view in
            view.backgroundColor =  UIColor(hexString: "F3F5F8")
        }
        
    }
    func selectedTab(_ type : LeaderBoardTypeFilter){
        unSelectAllView()
        switch type {
        case .friends:
            selectedTab(with: 0)
            break
        case .national:
            selectedTab(with: 3)
            break
        case .school:
            selectedTab(with: 1)
            break
        
        }
        
    }
    
    private func selectedTab(with id : Int){
        let view = tabBGV.first(where: {$0.tag == id})
        
        view?.backgroundColor = UIColor(hexString: "EBF8EF")
    }
    
    @IBAction func changeSegmentController(_ sender : UISegmentedControl){
        if let change = tabChange {
            change(sender.selectedSegmentIndex)
        }
    }
    
    func beginSkeltonAnimation() {
       
//        layoutIfNeeded()
//
//        var views: [UIView] = []
//        views.append(contentsOf: tabLabels)
//        views.append(contentsOf: tabSeperators)
//        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
//        var views: [UIView] = []
//        views.append(contentsOf: tabLabels)
//        views.append(contentsOf: tabSeperators)
//        views.forEach { $0.stopSkelting() }
    }
    
    
}
