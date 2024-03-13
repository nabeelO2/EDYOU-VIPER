//
//  BaseController.swift
//  EDYOU
//
//  Created by imac3 on 11/03/2024.
//

import UIKit
import SwiftMessages
import PanModal

class BaseController: UIViewController {

    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    // MARK: - Utility Methods
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
        
    }

    func showErrorWith(message: String){

        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 3)
        
        let error = MessageView.viewFromNib(layout: .cardView)
        
        let iconImage = IconStyle.default.image(theme: .error)
        error.configureTheme(backgroundColor: .blue, foregroundColor:  UIColor.white, iconImage: iconImage)
        
        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }
    
    func showSuccessMessage(message: String){
        
        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 2)
        let error = MessageView.viewFromNib(layout: .cardView)
        error.configureTheme(.success)
        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }

    func handleViewLoading(enable: Bool) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.view.isUserInteractionEnabled = enable
        }
    }
    
//    func handleError(error: ErrorResponse?) {
//        if let error = error {
//            self.showErrorWith(message: error.message)
//        }
//        self.handleViewLoading(enable: true)
//    }
    
    func showConfirmationAlert(title: String, description: String, buttonTitle: String, style: UIAlertAction.Style, alertStyle: UIAlertController.Style = .alert ,onConfirm: @escaping ()->Void, onCancel: (()->Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: description, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            onCancel?()
        }))
        alert.addAction(UIAlertAction(title: buttonTitle, style: style, handler: { _ in
            onConfirm()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, description: String, onOk: (()->Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            onOk?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    /// pop back n viewcontroller
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
}

//extension BaseController {
//    func showEmojiController(_ isFromStory : Bool = false,completion: @escaping (_ selected: String) -> Void) {
//        if #available(iOS 15 , *) {
//            let controller = EmojiPickerViewController { selectedEmoji in
//                print(completion)
//                completion(String(selectedEmoji.character))
//            }
//            if isFromStory{
//                controller.onDismissController = {
//                    completion("")
//                }
//            }
//            controller.modalPresentationStyle = .pageSheet
//            let sheet = controller.sheetPresentationController!
//            sheet.delegate = self
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersGrabberVisible = true
//            if let vc = self.parent{
//                vc.present(controller, animated: true, completion: nil)
//            }
//            else{
//                self.present(controller, animated: true, completion: nil)
//            }
//            
//        } else {
//            let controller = EmojisController { (selectedEmoji) in
//                completion(selectedEmoji)
//            }
//            self.present(controller, animated: true, completion: nil)
//        }
//    }
//}

extension BaseController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("EmojiPickerViewController did dismiss.")
    }
}

//extension BaseController {
//    func getCameraOfType(type: CameraController.CaptureType, delegate: CameraControllerDelegate, music: [AudioInfo] = []) -> CameraController {
//        let config = CameraConfiguration()
//        config.position = .front
//        config.videoMaximumDuration = 20
//        config.sessionPreset = .hd1280x720
//        config.allowLocation = false
//        let videoEditorConfiguration = VideoEditorConfiguration()
//        videoEditorConfiguration.exportPreset = .ratio_1280x720
//        var cropTimeConfig = VideoCropTimeConfiguration()
//        cropTimeConfig.maximumVideoCroppingTime = 20
//        videoEditorConfiguration.cropTime = cropTimeConfig
//        
//        var musicConfig = VideoEditorConfiguration.Music.init()
//        var musicInfoArray : [VideoEditorMusicInfo] = []
//        for object in music {
//            if let url = object.toURL {
//                musicInfoArray.append(VideoEditorMusicInfo.init(audioURL: url, lrc: "[ti:\(object.title ?? "")]\n[ar:\(object.artist ?? "")]\n[t_time:\(object.duration ?? 0)]"))
//            }
//        }
//        musicConfig.infos = musicInfoArray
//        videoEditorConfiguration.music = musicConfig
//        config.videoEditor = videoEditorConfiguration
//        #if canImport(GPUImage)
//        config.defaultFilterIndex = 0
//        config.photoFilters = FilterTools.filters()
//        config.videoFilters = FilterTools.filters()
//        #endif
//        let camerController = CameraController(config: config, type: .video)
//        camerController.autoDismiss = false
//        camerController.cameraDelegate = delegate
//        camerController.config.tintColor = UIColor(named: "EdYouGreen")!
//        camerController.modalPresentationStyle = .fullScreen
//        return camerController
//    }
//    
//    func saveVideoToGallery(videoURL: URL, completion: @escaping (Bool) -> Void) {
//        AssetManager.saveSystemAlbum(forAsset: videoURL, mediaType: .video) { asset in
//            if asset == nil {
//                self.showErrorWith(message: "Video is not saved")
//            }
//            completion(asset != nil)
//        }
//    }
//}
//
//// MARK: - All Reactions
//extension BaseController {
//    func showAllReactions(emojis:[EmojiModelProtocol],_ closeCallback: (()->Void)? = nil) {
//        let controller = AllReactionViewController(nibName: "AllChatReactionsController", bundle: nil)
//        controller.emojis = emojis
//        controller.closeCallback = closeCallback
//        self.presentPanModal(controller)
//    }
//}
