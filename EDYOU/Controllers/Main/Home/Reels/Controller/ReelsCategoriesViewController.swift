//
//  ReelsCategoriesViewController.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/08/2022.
//

import UIKit

protocol ReelsCategoryProtocol {
    func reelsCategorySelected(category: ReelsCategories)
}

class ReelsCategoriesViewController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    private var categoryProtocol: ReelsCategoryProtocol?
    
    lazy var adapater = ReelsCategoryAdapter(tableView: self.tableView, selectionProtocol: self.categoryProtocol)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    init(categoryProtocol: ReelsCategoryProtocol) {
        self.categoryProtocol = categoryProtocol
        super.init(nibName: ReelsCategoriesViewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.categoryProtocol = nil
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adapater.reloadData()
    }
    @IBAction func actClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
