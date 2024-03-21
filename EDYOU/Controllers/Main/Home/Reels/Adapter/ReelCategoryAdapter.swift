//
//  ReelCategoryAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 11/08/2022.
//

import Foundation
import UIKit

class ReelsCategoryAdapter: NSObject {
    var tableView: UITableView!
    var selectionProtocol: ReelsCategoryProtocol?
    
    let categories = ReelsCategories.allCases
    private var gradientView: UIImageView = {
        let imageView = UIImageView(image: UIImage.init(named: "ic_reels_bottom"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    private var paddingView: UIView = {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        return view
    }()
    init(tableView : UITableView, selectionProtocol: ReelsCategoryProtocol?) {
        super.init()
        self.tableView = tableView
        self.selectionProtocol = selectionProtocol
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ReelCategoryTableViewCell.nib, forCellReuseIdentifier: ReelCategoryTableViewCell.identifier)
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
}

extension ReelsCategoryAdapter : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReelCategoryTableViewCell.identifier, for: indexPath) as! ReelCategoryTableViewCell
        cell.setData(data: categories[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return gradientView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return paddingView.bounds.height
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return paddingView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionProtocol?.reelsCategorySelected(category: categories[indexPath.row])
    }
}
