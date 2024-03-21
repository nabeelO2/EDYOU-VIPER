//
//  ReelsViewController.swift
//  EDYOU
//
//  Created by Masroor Elahi on 11/08/2022.
//

import UIKit
//import HXPHPicker
import CoreLocation

class ReelsViewController: BaseController {

    // MARK: - Outlets
    
    @IBOutlet weak var constSelectorWidth: NSLayoutConstraint!
    @IBOutlet weak var constSelectorLeading: NSLayoutConstraint!
    @IBOutlet weak var btnCategories: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK: - Properties
    @IBOutlet weak var typeStack: UIStackView!
    var musicFiles: [AudioInfo] = []
    lazy var reelsAdapter = ReelsAdapter(collectionView: self.collectionView, parent: self)
    var selectedType = ReelsType.following
    private var selectorWidthPadding: CGFloat = 5
    private var selectorLeadingPadding: CGFloat = 8
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")
        self.registerNotification()
        self.loadMusic()
        self.prepareUI()
        // Do any additional setup after loading the view.
        self.loadReelsData(reload: true)
    }
    
    func prepareUI() {
        self.manageSelectorUI()
    }
    @IBAction func actClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actLoadReelOfType(_ sender: UIButton) {
        self.selectedType = ReelsType(rawValue: sender.tag)!
        if self.selectedType == .category {
            self.loadCategoriesScreen()
        } else {
            self.manageSelectorUI()
        }
    }
    
    @IBAction func actCreateReels(_ sender: UIButton) {
        self.showCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotification()
        self.reelsAdapter.handleViewDisappear()
    }
    
    // MARK: - Get Reels Data
    func loadReelsData(reload: Bool) {
        self.handleViewLoading(enable: true)
        APIManager.social.getReelsData(skip: reload ? 0 : self.reelsAdapter.reelsCount, limit: 100) { [weak self] reels, error, skip in
            guard let self = self else { return }
            if let error = error {
                self.handleError(error: error)
            } else {
                if skip != 0 {
                    var updateReels = self.reelsAdapter.reels
                    updateReels.append(contentsOf: reels ?? [] )
                    self.reelsAdapter.reels = updateReels
                } else {
                    self.reelsAdapter.resetAdapted()
                    self.reelsAdapter.reels = reels ?? []
                }
            }
        }
    }
}

// MARK: - Adapater Actions
extension ReelsViewController {
    func showCommentsOfReel(reel: Reels) {
        let controller = ReelsCommentsController(reels: reel)
        self.present(controller, presentationStyle: .formSheet)
    }
}

private extension ReelsViewController {
    func manageSelectorUI() {
        self.typeStack.arrangedSubviews.forEach { view in
            view.alpha = 0.8
            if view.tag == self.selectedType.rawValue {
                view.alpha = 1.0
                self.constSelectorWidth.constant = view.frame.width + selectorWidthPadding
                self.constSelectorLeading.constant = selectorLeadingPadding + view.frame.origin.x - (selectorWidthPadding / 2.0)
            }
        }
    }
   
}

extension ReelsViewController : ReelsCategoryProtocol {
    
    func reelsCategorySelected(category: ReelsCategories) {
        if category == .categories {
            self.selectedType = ReelsType.following
        }
        self.btnCategories.setTitle(category.description, for: .normal)
        self.btnCategories.layoutIfNeeded()
        self.presentedViewController?.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            self?.manageSelectorUI()
        }
    }
    
    private func loadCategoriesScreen() {
        let controller = ReelsCategoriesViewController(categoryProtocol: self)
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
}

// MARK: - Camera Picker and Delegate
extension ReelsViewController: CameraControllerDelegate {
    func cameraController(_ cameraController: CameraController, didFinishWithSelectedView result: [UIView]) {
        
    }
    
    
    func showCamera() {
        let cameraController = self.getCameraOfType(type: .video, delegate: self, music: self.musicFiles)
        self.present(cameraController, animated: true)
        self.reelsAdapter.handleViewDisappear()
    }
    
    func cameraController(didCancel cameraController: CameraController) {
        cameraController.dismiss(animated: true) {
            self.reelsAdapter.handleViewAppear()
        }
    }
    func cameraController(_ cameraController: CameraController, didFinishWithResult result: CameraController.Result, location: CLLocation?) {
        
        cameraController.dismiss(animated: true) { [weak self] in
            switch result {
            case .image(_):
                break;
            case .video(let url):
                self?.postReelsForData(url: url)
            case .any(_):
                break;
            }
        }
    }
    
}

// MARK: - Show Reels Post Controller
extension ReelsViewController: ReelsPostDelegate {
    
    func postReelsForData(url: URL) {
        let controller = ReelsPostViewController.init(videoURL: url, delegate: self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func reelSubmitted() {
        self.loadReelsData(reload: true)
    }
    func backToReels() {
        self.reelsAdapter.handleViewAppear()
    }
}

extension ReelsViewController {
    func loadMusic() {
        APIManager.social.getAllMusic { [weak self] audios, error in
            self?.musicFiles = audios ?? []
        }
    }
}

// MARK: - Application - Background - Foreground Notification
extension ReelsViewController {
    func registerNotification() {
        self.removeNotification()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func removeNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        self.reelsAdapter.handleViewDisappear()
   }

   @objc func appCameToForeground() {
       self.reelsAdapter.handleViewAppear()
   }
}
