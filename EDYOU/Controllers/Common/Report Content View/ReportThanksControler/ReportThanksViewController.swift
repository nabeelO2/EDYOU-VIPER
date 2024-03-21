//
//  ReportThanksViewController.swift
//  EDYOU
//
//  Created by Jamil Macbook on 17/1/23.
//

import UIKit

class ReportThanksViewController: BaseController {

    var reportObject: ReportContent?
    @IBOutlet var labelBlockUserName: UILabel!
    @IBOutlet var labelUnFollowUserName: UILabel!
    @IBOutlet var circleImageBlockUser: UIImageView!
    @IBOutlet var circleImageUnFollowUser: UIImageView!
    var isUserBlockSelected: Bool = false
    var isUserUnFollowSelected: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        labelBlockUserName.text = "Block " + (reportObject?.userName ?? "")
        labelUnFollowUserName.text = "UnFollow " + (reportObject?.userName ?? "")

        // Do any additional setup after loading the view.
    }


    @IBAction func didTapDoneButton(_ sender: UIButton) {
        if isUserBlockSelected {
            blockUser()
        } else if isUserUnFollowSelected {
            unfollowUser()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func unfollowUsersButtonTap() {
        isUserUnFollowSelected = !isUserUnFollowSelected
        circleImageUnFollowUser.image = UIImage(named:  isUserUnFollowSelected ? "fill_circle":"empty_cirle")
        circleImageBlockUser.image = UIImage(named: "empty_cirle")
        isUserBlockSelected = false
    }
    
    @IBAction func blockUsersButtonTap() {
        isUserBlockSelected = !isUserBlockSelected
        circleImageBlockUser.image = UIImage(named: isUserBlockSelected ? "fill_circle":"empty_cirle")
        circleImageUnFollowUser.image = UIImage(named: "empty_cirle")
        isUserUnFollowSelected = false

    }
    


}

extension ReportThanksViewController {
    func blockUser() {
        self.startLoading(title: "")
        APIManager.social.addBlockUser(userid: (reportObject?.userID)!) { error in
            self.stopLoading()
            if error != nil {
                self.showErrorWith(message: error!.message)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }

    }
    
    func unfollowUser() {
        self.startLoading(title: "")
        APIManager.reportContentManager.unfollowUser(userID: (reportObject?.userID)!) { response, error in
            self.stopLoading()
            if let err = error {
                self.showErrorWith(message: err.message)
            } else {
                self.navigationController?.popToRootViewController(animated: true)

            }
        }

    }
}
