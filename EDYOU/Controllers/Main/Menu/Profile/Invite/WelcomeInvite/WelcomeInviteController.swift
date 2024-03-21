//
//  WelcomeInviteController.swift
//  EDYOU
//
//  Created by imac3 on 21/04/2023.
//

import UIKit

class WelcomeInviteController: BaseController {
    
    @IBOutlet weak var historyTblV : UITableView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var totalInvitesLbl : UILabel!
    
    let minHeight : CGFloat = 64
    var maxHeight : CGFloat = 500
    
    var adapter : HistoryAdapter!
    var swipeDirection : Swipe = .unknown
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    @IBAction func didTapInvite(_ sender : UIButton) {
        //present invite screen
        let controller = InviteController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func shareInviteAction(_ sender : UIButton) {
         let id = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        print(id)
        
        invitedUser(id)
//        shareApp(<#T##String#>)
//        shareApp(getMessage("GTFV44A"))
    }
    
    private func invitedUser(_ address : String){
        
        let parameters : [String: Any]  = [
          "invite_source_type": "share",
          "invite_address": "\(address)"
        ]
    
        APIManager.social.inviteUser(parameters) { invitedUser,error  in
            if error != nil {
                self.showErrorWith(message: error!.message)
            } else {
                let currentRefferalCode = invitedUser?.referralCode ?? ""
               // print("invited user referal code: \(invitedUser?.referralCode)")
                self.shareApp(self.getMessage(currentRefferalCode))
                self.adapter.getInvitedUser()
            }
        }
    }
    private func getMessage(_ currentRefferalCode : String )->String{
        
        return "Hey Exciting news! I'm on EDYOU, the ultimate platform for college influencers.\nJoin me and let's become America's top college influencer together! Download the app now and let the journey begin\n\n \nhttps://edyouapp.com"
        
    }
    
    private func shareApp(_ message : String){
        
          let objectsToShare = [message]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          self.present(activityVC, animated: true, completion: nil)
        
    }
    func setupUI(){
        viewHeightConstraint.constant = minHeight
        addShadow()
        maxHeight = self.view.frame.height / 1.3
        adapter = HistoryAdapter(tableView: historyTblV)
        historyView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        historyView.addBorders(withEdges: [.top], withColor: .white, withThickness: 1.0, cornerRadius: 20)
        historyView.backgroundColor = R.color.navigationColor()
    }
    
    private func addShadow(){
        historyView.layer.shadowColor = UIColor.black.cgColor
        historyView.layer.shadowOpacity = 0.2
        historyView.layer.shadowOffset = CGSize(width: 0, height: -2)
        historyView.layer.shadowRadius = 4
        historyView.layer.masksToBounds = false
    }
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began, .changed:
            var newHeight = max(historyView.frame.size.height - translation.y, minHeight)
            newHeight = min(newHeight, maxHeight)
            //                print(newHeight)
            //                historyView.frame.size.height = newHeight
            swipeDirection = newHeight > viewHeightConstraint.constant ? .up : .down
            viewHeightConstraint.constant = newHeight
            gesture.setTranslation(.zero, in: view)
            self.view.layoutIfNeeded()
            break
        case .ended:
            
            switch swipeDirection {
            case .up:
                print("Swipe up")
                UIView.animate(withDuration: 0.5) { [self] in
                    viewHeightConstraint.constant = maxHeight
                    self.view.layoutIfNeeded()
                }
                break
            case .down:
                //print("Swipe down")
                UIView.animate(withDuration: 0.5) { [self] in
                    viewHeightConstraint.constant = minHeight
                    self.view.layoutIfNeeded()
                }
                break
            case .unknown:
                //  print("Swipe unknown")
                break
            }
            //
            //                let closestHeight = abs(viewHeightConstraint.constant - minHeight) < abs(viewHeightConstraint.constant - maxHeight) ? minHeight : maxHeight
            //
            //                viewHeightConstraint.constant = closestHeight
            break
        default:
            break
        }
    }
   
}

enum Swipe{
    case up
    case down
    case unknown
}

