//
//  RankCell.swift
//  EDYOU
//
//  Created by imac3 on 12/09/2023.
//

import UIKit

class RankCell: UITableViewCell {

    @IBOutlet weak var userProfileImg : UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var schoolLbl : UILabel!
    @IBOutlet weak var instituteLbl : UILabel!
    @IBOutlet weak var pointsLbl : UILabel!
    @IBOutlet weak var crownImg : UIImageView!
    @IBOutlet weak var rankLbl : UILabel!
    @IBOutlet weak var pointsImg : UIImageView!
    @IBOutlet weak var topSepratorV : UIView!
    @IBOutlet weak var bottomSepratorV : UIView!
    @IBOutlet weak var rightSepratorV : UIView!
    @IBOutlet weak var leftSepratorV : UIView!
    @IBOutlet weak var bgV : UIView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(_ leader : Leader) {
        if let user = leader.user{
            
            userProfileImg.setImage(url: user.profileImage, placeholder: UIImage(named: "placeholder"))
            
            nameLbl.text = user.name?.completeName.capitalized
            instituteLbl.text = user.college
            rankLbl.text = "\(leader.rank ?? 0)"
            pointsLbl.text = "\(leader.score ?? 0) points"
            schoolLbl.text = user.college
        }
        
    }
    
    func beginSkeltonAnimation() {
        crownImg.isHidden = true
        userProfileImg.isHidden = true
        layoutIfNeeded()
       
        let views: [UIView] = [userProfileImg, nameLbl, instituteLbl, pointsLbl, rankLbl, topSepratorV, rightSepratorV, leftSepratorV, bottomSepratorV,pointsImg,bgV]
        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
        crownImg.isHidden = false
        userProfileImg.isHidden = false
        let views: [UIView] = [userProfileImg, nameLbl, instituteLbl, pointsLbl, rankLbl,topSepratorV, rightSepratorV, leftSepratorV, bottomSepratorV,pointsImg,bgV]
        views.forEach { $0.stopSkelting() }
    }
    
     func emptyUserInfo(){
        userProfileImg.image = nil
        nameLbl.text = ""
        instituteLbl.text = ""
        pointsLbl.text = ""
        
       
    }
}
