//
//  CreateNewController.swift
//  EDYOU
//
//  Created by Aksa on 21/08/2022.
//

import UIKit
import PanModal

protocol CreateNewOptionsProtocol {
    func createPost()
    func createStory()
    func createReels()
}

class CreateNewController: BaseController {
    // MARK: - Outlets
    private var delegate:CreateNewOptionsProtocol?
    init(delegate: CreateNewOptionsProtocol) {
        self.delegate = delegate
        super.init(nibName: CreateNewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Controller life Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBActions
    @IBAction func createClipBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.createReels()
        }
    }
    
    @IBAction func createPostBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.createPost()
        }
        
    }
    
    @IBAction func createStoryBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.createStory()
        }
    }
    
    @IBAction func closeSheetBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - PanModal
extension CreateNewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return self.view as? UIScrollView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(270)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
}
