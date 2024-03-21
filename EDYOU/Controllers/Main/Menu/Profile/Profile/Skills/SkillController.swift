//
//  AddSkillViewController.swift
//  EDYOU
//
//  Created by Masroor on 14/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit
import TagListView
import TransitionButton

class SkillController: BaseController {
    
    @IBOutlet weak var svContainer: UIStackView!
    var user:User!
    @IBOutlet weak var skillTagView: TagListView!
    @IBOutlet weak var txtSkill: BorderedTextField!
    @IBOutlet weak var lblTitle: UILabel!
    var userSkill: String!
    @IBOutlet weak var btnSave: TransitionButton!
    var isEditMode: Bool = false
    var suggestedSkills = ["Python", "HTML5", "JavaScript", "CSS", "PHP", "SQL", "C++", "Ruby", ".NET","Linux", "Windows", "masOS", "Android", "iOS"]
    var tittle: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setSkills(skills: self.suggestedSkills)
        skillTagView.delegate = self
        txtSkill.text = userSkill
        if !self.userSkill.isEmpty {
            lblTitle.text = "Edit Skill"
            self.isEditMode = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actBack(_ sender: UIButton) {
        self.goBack()
    }
    func setSkills(skills: [String]) {
        skillTagView.removeAllTags()
        skillTagView.textFont =  .systemFont(ofSize: 12)
        skillTagView.addTags(skills)
    }
    
    init(skill: String) {
        self.userSkill = skill
        super.init(nibName: SkillController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func actSavePressed(_ sender: UIButton) {
        if !txtSkill.validate() { return }
        if isEditMode {
            deleteSkill(skill: userSkill) {
                self.addSkill()
            }
        } else {
            addSkill()
        }
    }
    
    @IBAction func actCloseSuggestions(_ sender: UIButton) {
        skillTagView.superview?.isHidden = true
    }
    
    func addSkill(animateButton: Bool = true) {
//        btnSave.startAnimation()
//        self.handleViewLoading(enable: false)
//        self.sendUpdateSkillRequest(skill: txtSkill.text ?? "", added: true) {[weak self] error in
//            self?.btnSave.stopAnimation()
//            self?.handleViewLoading(enable: true)
//            if error == nil {
//                self?.goBack()
//            } else {
//                self?.showErrorWith(message: error!.message)
//            }
//        }
        
        if let text = txtSkill.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            btnSave.startAnimation()
            self.handleViewLoading(enable: false)
            self.sendUpdateSkillRequest(skill: text, added: true) {[weak self] error in
                self?.btnSave.stopAnimation()
                self?.handleViewLoading(enable: true)
                if error == nil {
                    self?.goBack()
                } else {
                    self?.showErrorWith(message: error!.message)
                }
            }
        }
        else{
            showErrorWith(message: "Skill can't be empty")
        }

    }
    
    
    func deleteSkill(skill:String, completion: @escaping ()->Void) {
        self.handleViewLoading(enable: false)
        self.sendUpdateSkillRequest(skill: skill, added: false) {
            [weak self] error in
            guard let self = self else { return }
            self.handleViewLoading(enable: true)
            if error == nil {
                completion()
            }
            else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    private func sendUpdateSkillRequest(skill: String, added: Bool, completion: @escaping (ErrorResponse?)->Void) {
        APIManager.social.updateSkill(skill: skill, isAdd: added, completion: completion)
    }
}

extension SkillController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
        txtSkill.text = title
    }
}
