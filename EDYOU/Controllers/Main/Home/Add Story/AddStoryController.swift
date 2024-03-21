//
//  AddStoryController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit
import TransitionButton

class AddStoryController: BaseController {

    @IBOutlet weak var clvBackgrounds: UICollectionView!
    @IBOutlet weak var viewBg: GradientView!
    @IBOutlet weak var viewBgColorIndicator: GradientView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var txtStory: UITextView!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var cstTxtStoryBottom: NSLayoutConstraint!
    @IBOutlet weak var cstScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var btnDone: TransitionButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textTopView: UIView!
    @IBOutlet weak var imageTopView: UIView!
    
    enum Tabs: Int {
        case text, gallery
    }
    
    var selectedTab: Tabs = .text
    
    var bgAdapter: ColorsBgAdapter!
    var images = [UIImage]()
    var medias = [Media]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAdapters()
        setupUI()
        setTab(index: 0, animated: false)
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        
        if frame.height > 0 {
            let h = frame.height - Application.shared.safeAreaInsets.bottom - 60
            cstScrollViewBottom.constant = h > 0 ? h : 0
        } else {
            cstScrollViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
        
    }
    
}

// MARK: - Actions
extension AddStoryController {
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        goBack()
    }
    @IBAction func didTapTabButton(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            if selectedTab != Tabs(rawValue: sender.tag) {
                txtStory.text = ""
            }
            
            setTab(index: sender.tag)
            viewImage.isHidden = true
            scrollView.isHidden = false
            clvBackgrounds.isHidden = false
            
        } else if sender.tag == 1 {
            self.setTab(index: 1)
            ImagePicker.shared.openGalleryUsingHXPHImagePicker(from: self) { mediaFiles in
                self.stopLoading()
                self.medias = mediaFiles
                self.moveToStoryMediaFilesVC()
            }
        } else if sender.tag == 2 {
            ImagePicker.shared.openCameraWithType(from: self, mediaType: Constants.imageMediaType) {[weak self] data in
                guard let self = self else { return }
                self.setTab(index: 2)
                self.imgStory.image = data.image
                self.viewImage.isHidden = false
                self.scrollView.isHidden = true
            }
        }
        
    }
    @IBAction func didTapImageTextButton(_ sender: UIButton) {
        scrollView.isHidden = false
        clvBackgrounds.isHidden = true
        txtStory.becomeFirstResponder()
    }
    @IBAction func didTapDoneButton(_ sender: UIButton) {
        if selectedTab == .text && txtStory.text.count > 0 {
            createStory()
        } else if imgStory.image != nil {
            createStory()
        } else {
            sender.shake()
        }
        
    }
    
}

// MARK: - Utility Methods
extension AddStoryController {
    func configureAdapters() {
        bgAdapter = ColorsBgAdapter(collectionView: clvBackgrounds, didSelect: { [weak self] bg in
            guard let self = self else { return }
            
            self.viewBg.colors = bg.colors
            self.viewBg.startPoint = bg.startPoint
            self.viewBg.endPoint = bg.endPoint
            
            self.viewBgColorIndicator.colors = bg.colors
            self.viewBgColorIndicator.startPoint = bg.startPoint
            self.viewBgColorIndicator.endPoint = bg.endPoint
            
        })
        bgAdapter.selectedBorderColor = .white
        bgAdapter.selectedBorderWidth = 2
        bgAdapter.selectedIndex = 1
    }
    func addData(data: Data, isImage: Bool) {
        if isImage {
            if let image = UIImage(data: data) {
                images.append(image)
            } else {
                images.append(UIImage(named: "black_image") ?? UIImage())
            }
            medias.append(Media(withData: data, key: "images", mimeType: .image))
        } else {
            images.append(UIImage(named: "video_placeholder_icon") ?? UIImage())
            medias.append(Media(withData: data, key: "videos", mimeType: .video))
        }
        
    }
    func setupUI() {
        viewBg.colors = ["0088FF".color, "0092FF".color]
        viewBgColorIndicator.colors = viewBg.colors
    }
    
    func setTab(index: Int, animated: Bool = true) {
        selectedTab = Tabs(rawValue: index) ?? .text
        switch selectedTab {
        case .text:
            self.textTopView.isHidden = false
            self.imageTopView.isHidden = true

        case .gallery:
            self.imageTopView.isHidden = false
            self.textTopView.isHidden = true

        }
        //let padding = ((view.width / 3) - viewIndicator.width) / 2
        //cstViewIndicatorLeading.constant = (CGFloat(index) * (view.width / 3)) + padding
        view.layoutIfNeeded(animated)
    }
    func moveToStoryMediaFilesVC() {
        let navC = self.tabBarController?.navigationController ?? self.navigationController
        let controller = StoryMediaFilesViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.mediaFiles = self.medias
        navC?.pushViewController(controller, animated: true)
    }
}

// MARK: - TextView Delegate
extension AddStoryController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.textAlignment = (textView.text ?? "").count > 0 ? .center : .left
        lblPlaceholder.isHidden = (textView.text ?? "").count > 0
    }
}

extension AddStoryController {
    func createStory() {
        
        var colors = ""
        var colorPositions = ""
        colors = viewBg.colors.hexStrings.joined(separator: ", ")
        colorPositions = "(\(viewBg.startPoint.x), \(viewBg.startPoint.y)), (\(viewBg.endPoint.x), \(viewBg.endPoint.y))"
        
        let n = (txtStory.text ?? " ")
        let parameters: [String: Any] = [
            "post_name" : n,
            "background_colors": colors,
            "background_colors_position": colorPositions,
            "is_background": selectedTab == .text,
            "post_type": "story",
            "post_deletion_settings": "a_day",
            "privacy": "friends"
        ]
            var images = [Media]()
            if selectedTab != .text, let img = imgStory.image, let m = Media(withImage: img, key: "images") {
                images.append(m)
            }
            
            view.endEditing(true)
            view.isUserInteractionEnabled = false
            progressBar.isHidden = false
            self.addBlurView(top: progressBar.bottom, bottom: 0, left: 0, right: 0, style: .dark)
            btnDone.startAnimation()
            
            
            APIManager.fileUploader.createPost(parameters: parameters, media: images) { [weak self] progress in
                guard let self = self else { return }
                self.progressBar.progress = progress
            } completion: { [weak self] response, error in
                guard let self = self else { return }
                
                self.progressBar.isHidden = true
                self.btnDone.stopAnimation()
                self.removeBlurView()
                self.popBack(2)
                
                self.view.isUserInteractionEnabled = true
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorWith(message: error!.message)
                }
                
            }
        
    }
}
