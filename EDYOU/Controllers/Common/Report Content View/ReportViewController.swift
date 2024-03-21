//
//  ReportViewController.swift
//  EDYOU
//
//  Created by Jamil Macbook on 28/12/22.
//

import UIKit

class ReportViewController: BaseController {

    @IBOutlet weak var tableView: UITableView!

    private var adapter: ReportAdapter!
    var reportObject: ReportContent?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        adapter = ReportAdapter(with: tableView, reportContentObject: reportObject!)
        // Do any additional setup after loading the view.
    }

   
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
   
}
