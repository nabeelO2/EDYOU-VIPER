//
//  ExperienceTypeViewController.swift
//  EDYOU
//
//  Created by Masroor Elahi on 07/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit
import PanModal

protocol ExperienceTypeSelectedProtocol {
    func experienceTypeSelected(type: JobType)
}

class ExperienceTypeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let jobType: JobType?
    let delegate: ExperienceTypeSelectedProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableView()
    }
    
    init(jobType: JobType?, delegate: ExperienceTypeSelectedProtocol?) {
        self.jobType = jobType
        self.delegate = delegate
        super.init(nibName: ExperienceTypeViewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.jobType = nil
        self.delegate = nil
        super.init(coder: coder)
    }
    deinit {
        print("[ExperienceTypeViewController] deinit")
    }
    
    func registerTableView() {
        self.tableView.register(ExperienceTypeTableViewCell.nib, forCellReuseIdentifier: ExperienceTypeTableViewCell.identifier)
    }
    
    @IBAction func actClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension ExperienceTypeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JobType.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExperienceTypeTableViewCell.identifier, for: indexPath) as! ExperienceTypeTableViewCell
        let jobType = JobType.allCases[indexPath.row]
        cell.setData(type: jobType, checked: self.jobType == jobType)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let job = JobType.allCases[indexPath.row]
        self.delegate?.experienceTypeSelected(type: job)
        self.dismiss(animated: true)
    }
}

extension ExperienceTypeViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tableView
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
}
