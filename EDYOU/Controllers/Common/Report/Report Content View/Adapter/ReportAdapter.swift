//
//  ReportAdapter.swift
//  EDYOU
//
//  Created by Jamil Macbook on 28/12/22.
//

import Foundation
import UIKit

class ReportAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: ReportViewController? {
        return tableView.viewContainingController() as? ReportViewController
    }
    var tableData = ["Spam", "Copied Content", "Adult Content", "False Information", "Nudity or sexual activity", "Violence and hostility", "Other"]
    var reportObject: ReportContent?

    init(with tableView: UITableView, reportContentObject: ReportContent) {
        super.init()
        
        self.tableView = tableView
        reportObject = reportContentObject
        tableView.register(ExperienceTypeTableViewCell.nib, forCellReuseIdentifier: ExperienceTypeTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        self.setTableHeader()
        
    }
    
    func setTableHeader() {
        let headerView =  UIView(frame: CGRect(x: 0, y: 0, width: self.parent?.view.frame.size.width ?? 200, height: 80))
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: headerView.frame.size.width - 30, height: 60))
        label.text = "What do you want to report this content for?"
        label.font = UIFont(name: "SF Pro Display Medium", size: 20)
        label.numberOfLines = 0
        headerView.addSubview(label)
        tableView.tableHeaderView = headerView
    }
    
}


// MARK: - TableView DataSource and Delegate
extension ReportAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExperienceTypeTableViewCell.identifier, for: indexPath) as! ExperienceTypeTableViewCell
        cell.setData(titleLabel: tableData[indexPath.row], checked: false)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navC =  self.parent?.tabBarController?.navigationController ?? self.parent?.navigationController 
        let controller = ReportSubViewController(nibName: "ReportSubViewController", bundle: nil)
        reportObject?.reportType = getReportType(row: indexPath.row)
        controller.screenTitle = tableData[indexPath.row]
        controller.reportObject = reportObject
        navC?.pushViewController(controller, animated: true)
    }
}

extension ReportAdapter {

    func getReportType(row: Int) -> String {
        switch row {
        case 0:
            return "spam_content"
        case 1:
            return "copied_content"
        case 2:
            return "adult_content"
        case 3:
            return "false_content"
        case 4:
            return "sexual_content"
        case 5:
            return "violience_content"
        case 6:
            return "other_content"
        default:
            return "spam_content"
        }
    }
    
}
