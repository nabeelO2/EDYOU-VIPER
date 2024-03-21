//
//  PRTextWithBgPostCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import ActiveLabel
import TransitionButton


class PPTextWithBgPostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var btnApprove: TransitionButton!
    @IBOutlet weak var btnDecline: TransitionButton!
    
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ data: Post?) {
        self.post = data
        
        imgProfile.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = data?.user?.name?.completeName ?? "N/A"
        lblInstituteName.text = data?.user?.college ?? "N/A"
        lblPost.text = data?.formattedText
        
        
        gradientView.colors = [UIColor(red: 70 / 255, green: 79 / 255, blue: 245 / 255, alpha: 1),
                               UIColor(red: 151 / 255, green: 76 / 255, blue: 214 / 255, alpha: 1),
                               UIColor(red: 231 / 255, green: 96 / 255, blue: 196 / 255, alpha: 1)
        ]
        
        let colors = data?.backgroundColors?.components(separatedBy: ", ").colors ?? []
        if let points = data?.backgroundColorsPosition?.components(separatedBy: "), (") {
            if points.count >= 2 {
                let p1 = points[0].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                let p2 = points[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                
                gradientView.colors = colors
                gradientView.startPoint = CGPoint(x: Double(p1.first ?? "0") ?? 0, y: Double(p1.last ?? "0") ?? 0)
                gradientView.endPoint = CGPoint(x: Double(p2.first ?? "0") ?? 0, y: Double(p2.last ?? "0") ?? 0)
                
            }
        }
        gradientView.updatePoints()
        
        lblPost.handleMentionTap { [weak self] tappedName in
            guard let self = self else { return }
            
            for u in (self.post?.tagFriendsProfile ?? []) {
                if let user = u {
                    let name = user.formattedUserName
                    if name == tappedName {
                        let controller = ProfileController(user: user)
                        let navC = self.viewContainingController()?.tabBarController?.navigationController ?? self.viewContainingController()?.navigationController
                        navC?.popToRootViewController(animated: false)

                        navC?.pushViewController(controller, animated: true)
                    }
                }
                
            }
        }
        
        
        
        
        
        
    }
    
}
