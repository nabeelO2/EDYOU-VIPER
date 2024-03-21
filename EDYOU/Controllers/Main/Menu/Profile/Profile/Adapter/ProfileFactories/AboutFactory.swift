//
//  AboutFactory.swift
//  EDYOU
//
//  Created by Masroor Elahi on 18/06/2022.
//

import Foundation
import UIKit

protocol AboutSectionCellDelegate {
    func onDelete(index: Int)
    func onEdit(index: Int)
}

class AboutFactory {
    var tableView : UITableView
    var parent: UINavigationController?
    var user: User?
    weak var updateProtocol: UserProfileUpdateProtocol?
    
    init(table: UITableView, navigationController: UINavigationController?) {
        self.tableView = table
        self.parent = navigationController
        self.registerCell()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func updateDelegate(profileUpdate: UserProfileUpdateProtocol) {
        self.updateProtocol = profileUpdate
    }
    
    func registerCell() {
        tableView.register(AboutTableCell.nib, forCellReuseIdentifier: AboutTableCell.identifier)
        tableView.register(ExperienceTableCell.nib, forCellReuseIdentifier: ExperienceTableCell.identifier)
        tableView.register(EducationTableCell.nib, forCellReuseIdentifier: EducationTableCell.identifier)
        tableView.register(CertificationTableCell.nib, forCellReuseIdentifier: CertificationTableCell.identifier)
        tableView.register(DocumentsTableCell.nib, forCellReuseIdentifier: DocumentsTableCell.identifier)
        tableView.register(ProfileAboutHeader.nib, forCellReuseIdentifier: ProfileAboutHeader.identifier)
        tableView.register(SkillTableCell.nib, forCellReuseIdentifier: SkillTableCell.identifier)
        tableView.register(EditSkillTableViewCell.nib, forCellReuseIdentifier: EditSkillTableViewCell.identifier)
    }
    
    func tableView(numberOfRowsInSection section: Int, user: User?, isEditMode: Bool = false) -> Int {
        let section = AboutSections(rawValue: section)!
        guard let user = user else {
            return 0
        }
        return section.getCells(user: user, isEditMode: isEditMode)
    }
    
    func numberOfSections() -> Int {
        return AboutSections.allCases.count
    }
    
    func tableView(cellForRowAt indexPath: IndexPath , friendshipStatus: FriendShipStatusModel, user: User?, delegate: AboutSectionCellDelegate?) -> UITableViewCell {
        let section = AboutSections(rawValue: indexPath.section)!
        var tableCell: UITableViewCell = UITableViewCell()
        switch section {
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableCell.identifier, for: indexPath) as! AboutTableCell
            cell.lblAboutDetail.text = user?.about
            tableCell = cell
        case .experiences:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExperienceTableCell.identifier, for: indexPath) as! ExperienceTableCell
            cell.setData(workExperience: user?.workExperiences.toArray(type: WorkExperience.self).object(at: indexPath.row) ?? WorkExperience.nilWorkExperince, delegate: delegate)
            tableCell = cell
        case .education:
            let cell = tableView.dequeueReusableCell(withIdentifier: EducationTableCell.identifier, for: indexPath) as! EducationTableCell
            cell.setData(education: user?.education.toArray(type: Education.self).object(at: indexPath.row) ?? Education.nilProperties, delegate: delegate)
            tableCell = cell
        case .certificates:
            let cell = tableView.dequeueReusableCell(withIdentifier: CertificationTableCell.identifier, for: indexPath) as! CertificationTableCell
            cell.setData(certficate: user?.userCertifications.toArray(type: UserCertification.self).object(at: indexPath.row) ?? UserCertification.nilCertificate, delegate: delegate)
            tableCell = cell
        case .skills:
            if(delegate == nil){
                let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableCell.identifier, for: indexPath) as! SkillTableCell
                cell.setData(skills: user?.skills.toArray(type: String.self) ?? [])
                tableCell = cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditSkillTableViewCell.identifier, for: indexPath) as! EditSkillTableViewCell
                cell.setData(skill: user?.skills.toArray(type: String.self).object(at: indexPath.row) ?? "", delegate: delegate)
                tableCell = cell
            }
        case .documents:
            let cell = tableView.dequeueReusableCell(withIdentifier: DocumentsTableCell.identifier, for: indexPath) as! DocumentsTableCell
            cell.btnView.addTarget(self, action: #selector(actViewDocument), for: .touchUpInside)
            cell.btnView.tag = indexPath.row
            cell.setData(doc: (user?.userDocuments.toArray(type: UserDocument.self).object(at: indexPath.row))!, delegate: delegate)
            tableCell = cell
        }
        let parentCell = tableCell as! AboutSectionParentCell
        parentCell.indexPath = indexPath
        parentCell.selectionStyle = .none
        return tableCell
    }
    
    @objc func didTapEditSkill(sender:UIButton){
        let controller = SkillController(skill: (user?.skills[sender.tag])!)
        controller.isEditMode = true
        self.parent?.pushViewController(controller, animated: true)
    }
    
    @objc func actViewDocument(_ sender: UIButton) {
        let doc = (user?.userDocuments.toArray(type: UserDocument.self).object(at: sender.tag))!
        let controller = DocumentViewerController(url: doc.documentURL ?? "", title: doc.documentTitle ?? "")
        let navC = parent
        controller.modalPresentationStyle = .fullScreen
        navC?.present(controller, animated: true)
    }
    
    func tableView(viewForHeaderInSection section: Int) -> UIView? {
        guard let user = user else { return nil}
        let headerView = tableView.dequeueReusableCell(withIdentifier: ProfileAboutHeader.identifier) as! ProfileAboutHeader
        headerView.btnEdit.tag = section
        headerView.btnAdd.tag = section
        headerView.btnEdit.addTarget(self, action: #selector(didTapSectionEdit(sender:)), for: .touchUpInside)
        headerView.btnAdd.addTarget(self, action: #selector(didTapSectionAdd(sender:)), for: .touchUpInside)
        let section = AboutSections(rawValue: section)!
        headerView.setUpView(section: section, user: user)
        return headerView
    }
    func tableView(heightForHeaderInSection section: Int) -> CGFloat {
        let section = AboutSections(rawValue: section)
        return (section != nil) ? 55 : 0
    }
    
}

// MARK: - About Actions
extension AboutFactory {
    @objc private func didTapSectionEdit(sender: UIButton) {
        if  Cache.shared.user?.userID != user?.userID { return }
        guard let user = Cache.shared.user else { return }
        let section = AboutSections(rawValue: sender.tag)!
        if section == .about {
            self.pushController(controller: AboutSections.getAboutController(user: user))
        } else {
            let controller = ProfessionalProfileController(tittle: section.descrption, user: user, type: AboutSections(rawValue: AboutSections.RawValue(sender.tag)) ?? .experiences)
            let navC = parent
            navC?.pushViewController(controller, animated: true)
        }
    }
    @objc private func didTapSectionAdd(sender: UIButton) {
        let section = AboutSections(rawValue: sender.tag)!
        var data:Any? = nil
        if section == .about {
            data = self.user
        }
        let controller: UIViewController = section.getController(data: data)
        self.pushController(controller: controller)
    }
}

extension AboutFactory {
    private func pushController(controller: UIViewController) {
        let navC = parent
        navC?.pushViewController(controller, animated: true)
    }
}
