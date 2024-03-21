//
//  GroupFilterController.swift
//  EDYOU
//
//  Created by Aksa on 04/09/2022.
//

import UIKit

protocol GroupFilterDelegate: AnyObject {
    func filterGroupPosts()
}

class GroupFilterController: BaseController {
    @IBOutlet weak var postPhotoBtn: UIButton!
    @IBOutlet weak var postVideoBtn: UIButton!
    @IBOutlet weak var postTextBtn: UIButton!
    @IBOutlet weak var postEventBtn: UIButton!
    
    weak var groupFIlterDelegate: GroupFilterDelegate?
    var feedFilterOption = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (AppDefaults.shared.groupFilterOption == "photo") {
            postPhotoBtn.isSelected = true
            postPhotoBtn.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.groupFilterOption == "video") {
            postVideoBtn.isSelected = true
            postVideoBtn.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.groupFilterOption == "text") {
            postTextBtn.isSelected = true
            postTextBtn.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.groupFilterOption == "event") {
            postEventBtn.isSelected = true
            postEventBtn.tintColor = UIColor.init(hexString: "53B36E")
        }
    }
    
    func clearAll() {
        postPhotoBtn.isSelected = false
        postVideoBtn.isSelected = false
        postTextBtn.isSelected = false
        postEventBtn.isSelected = false
        postPhotoBtn.tintColor = UIColor.init(hexString: "C4C4C4")
        postVideoBtn.tintColor = UIColor.init(hexString: "C4C4C4")
        postTextBtn.tintColor = UIColor.init(hexString: "C4C4C4")
        postEventBtn.tintColor = UIColor.init(hexString: "C4C4C4")
        AppDefaults.shared.groupFilterOption = ""
        feedFilterOption = ""
    }
    
    @IBAction func clearAllBtnTapped(_ sender: UIButton) {
        clearAll()
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        groupFIlterDelegate?.filterGroupPosts()
        goBack()
    }
    
    @IBAction func filterOptionTapped(_ sender: UIButton) {
        let tag = sender.tag
        clearAll()
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? UIColor.init(hexString: "53B36E") : UIColor.init(hexString: "C4C4C4")
        
        if (tag == 1) {
            feedFilterOption = "photo"
        } else if (tag == 2) {
            feedFilterOption = "video"
        } else if (tag == 3) {
            feedFilterOption = "text"
        } else if (tag == 4) {
            feedFilterOption = "event"
        }
    }
    
    @IBAction func applyFilterTapped(_ sender: UIButton) {
        if !feedFilterOption.isEmpty {
        AppDefaults.shared.groupFilterOption = feedFilterOption
        }
        groupFIlterDelegate?.filterGroupPosts()
        goBack()
    }
}
