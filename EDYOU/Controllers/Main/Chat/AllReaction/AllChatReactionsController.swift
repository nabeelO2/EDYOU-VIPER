//
//  AllChatReactionViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 11/08/2022.
//

import UIKit
import PanModal

class AllReactionViewController: BaseController {

    @IBOutlet weak var reactionCollectionView: UICollectionView!
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var mainView: UIView!
    var adapter: AllReactionsAdapter!
    var emojis :  [EmojiModelProtocol] = []
    var closeCallback: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = AllReactionsAdapter(tableView: usersTableView,collectionView: reactionCollectionView, emojis: emojis)
       // self.mainView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.mainView.addShadow(ofColor: UIColor.gray, radius: 10.0, offset: CGSize(width: 1, height: 1), opacity: 0.5)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let closeCallBack = closeCallback{
            closeCallBack()
        }
        
    }
    @IBAction func crossButtonTouched(_ sender: Any) {
        self.dismiss(animated: true)
        
       
    }
}

extension AllReactionViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
}
