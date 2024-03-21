//
//  AddTextController.swift
//  ustories
//
//  Created by imac3 on 27/06/2023.
//

import UIKit

class AddTextController: UIViewController {
    
    @IBOutlet weak var clvBackgrounds: UICollectionView!
    @IBOutlet weak var viewBg: HX_GradientView!
    @IBOutlet weak var viewBgColorIndicator: HX_GradientView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var txtStory: UITextView!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var cstTxtStoryBottom: NSLayoutConstraint!
    @IBOutlet weak var cstScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var viewImage: UIView!
//    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var textTopView: UIView!
//    @IBOutlet weak var imageTopView: UIView!
    
    var textHandler : (([String : Any])->Void)?
    
    enum Tabs: Int {
        case text, gallery
    }
    
    var selectedTab: Tabs = .text
    
    var bgAdapter: HX_ColorsBgAdapter!
    var images = [UIImage]()
   // var medias = [Media]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAdapters()
        setupUI()
//        setTab(index: 0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowNotification(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification(_ sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardWillChangeFrame(to: endFrame)
            }
        }
    }
    @objc private func keyboardWillHideNotification(_ sender: NSNotification) {
        keyboardWillChangeFrame(to: CGRect.zero)
    }
    
    
    func keyboardWillChangeFrame(to frame: CGRect) {
        
        
        let safeArea = view.safeAreaInsets
        if frame.height > 0 {
            let h = frame.height - safeArea.bottom
            cstScrollViewBottom.constant = h > 0 ? h : 0
        } else {
            cstScrollViewBottom.constant = 0
        }
//        view.layoutIfNeeded(true)

        view.layoutIfNeeded()
    }
    
}

// MARK: - Actions
extension AddTextController {
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
//        goBack()
    }
    @IBAction func didTapTabButton(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            
            
        } else if sender.tag == 1 {
            
        } else if sender.tag == 2 {
            
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
        }
//        else if imgStory.image != nil {
//            createStory()
//        }
        else {
//            sender.shake()
        }
        
    }
    
}

// MARK: - Utility Methods
extension AddTextController {
    func configureAdapters() {
        bgAdapter = HX_ColorsBgAdapter(collectionView: clvBackgrounds, didSelect: { [weak self] bg in
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
//            medias.append(Media(withData: data, key: "images", mimeType: .image))
        } else {
            images.append(UIImage(named: "video_placeholder_icon") ?? UIImage())
//            medias.append(Media(withData: data, key: "videos", mimeType: .video))
        }
        
    }
    func setupUI() {
        viewBg.colors = ["0088FF".hx_Color, "0092FF".hx_Color]
        viewBgColorIndicator.colors = viewBg.colors
    }
    
//    func setTab(index: Int, animated: Bool = true) {
//        selectedTab = Tabs(rawValue: index) ?? .text
//        switch selectedTab {
//        case .text:
//            self.textTopView.isHidden = false
//            self.imageTopView.isHidden = true
//
//        case .gallery:
//            self.imageTopView.isHidden = false
//            self.textTopView.isHidden = true
//
//        }
//        //let padding = ((view.width / 3) - viewIndicator.width) / 2
//        //cstViewIndicatorLeading.constant = (CGFloat(index) * (view.width / 3)) + padding
//        view.layoutIfNeeded()
//    }
    func moveToStoryMediaFilesVC() {
//        let navC = self.tabBarController?.navigationController ?? self.navigationController
//        let controller = StoryMediaFilesViewController()
//        controller.modalPresentationStyle = .fullScreen
//        controller.mediaFiles = self.medias
//        navC?.pushViewController(controller, animated: true)
    }
}

// MARK: - TextView Delegate
extension AddTextController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.textAlignment = (textView.text ?? "").count > 0 ? .center : .left
        lblPlaceholder.isHidden = (textView.text ?? "").count > 0
    
        let text = textView.text.trimmingCharacters(in: .whitespaces)
        btnDone.isEnabled = !text.isEmpty
        
    }
}

extension AddTextController {
    func createStory() {
        
        var colors = ""
        var colorPositions = ""
        colors = viewBg.colors.hexStringsHX.joined(separator: ", ")
        colorPositions = "(\(viewBg.startPoint.x), \(viewBg.startPoint.y)), (\(viewBg.endPoint.x), \(viewBg.endPoint.y))"
        
//
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
        
        dismiss(animated: true)
        if let action = textHandler {
            action(parameters)
        }
       
        
        
        
    }
}
