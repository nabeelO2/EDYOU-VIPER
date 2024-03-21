//
//  PreviewLivePhotoViewCell.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/3/12.
//

import UIKit

class PreviewLivePhotoViewCell: PhotoPreviewViewCell, PhotoPreviewContentViewDelete {
    
    var livePhotoPlayType: PhotoPreviewViewController.PlayType = .once {
        didSet {
            scrollContentView.livePhotoPlayType = livePhotoPlayType
        }
    }
    
    lazy var liveMarkView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        if let nav = UIViewController.topViewController?.navigationController, !nav.navigationBar.isHidden {
            view.hx_y = nav.navigationBar.frame.maxY + 5
        }else {
            if UIApplication.shared.isStatusBarHidden {
                view.hx_y = UIDevice.navigationBarHeight + UIDevice.generalStatusBarHeight + 5
            }else {
                view.hx_y = UIDevice.navigationBarHeight + 5
            }
        }
        view.hx_x = 5
        view.hx_height = 24
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        let imageView = UIImageView(image: "hx_picker_livePhoto".image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = "#666666".hx_Color
        imageView.hx_size = imageView.image?.size ?? .zero
        imageView.centerY = view.hx_height * 0.5
        imageView.hx_x = 5
        view.contentView.addSubview(imageView)
        let label = UILabel()
        label.text = "Live"
        label.textColor = "#666666".hx_Color
        label.textAlignment = .center
        label.font = .regularPingFang(ofSize: 15)
        label.hx_x = imageView.frame.maxX + 5
        label.hx_height = view.hx_height
        label.hx_width = label.textWidth
        view.hx_width = label.frame.maxX + 5
        view.contentView.addSubview(label)
        return view
    }()
    
    var liveMarkConfig: PreviewViewConfiguration.LivePhotoMark? {
        didSet {
            configLiveMark()
        }
    }
    override var photoAsset: PhotoAsset! {
        didSet {
//            #if HXPICKER_ENABLE_EDITOR
            if photoAsset.photoEdit != nil {
                liveMarkView.isHidden = true
            }
            else {
                if liveMarkConfig?.allowShow == true {
                    liveMarkView.isHidden = false
                }
            }
//            #else
//            if liveMarkConfig?.allowShow == true {
//                liveMarkView.isHidden = false
//            }
//            #endif
        }
    }
    func configLiveMark() {
        guard let liveMarkConfig = liveMarkConfig else {
            liveMarkView.isHidden = true
            return
        }
        if !liveMarkConfig.allowShow {
            liveMarkView.isHidden = true
            return
        }
        liveMarkView.effect = UIBlurEffect(
            style: PhotoManager.isDark ? liveMarkConfig.blurDarkStyle : liveMarkConfig.blurStyle
        )
        let imageView = liveMarkView.contentView.subviews.first as? UIImageView
        imageView?.tintColor = PhotoManager.isDark ? liveMarkConfig.imageDarkColor : liveMarkConfig.imageColor
        let label = liveMarkView.contentView.subviews.last as? UILabel
        label?.textColor = PhotoManager.isDark ? liveMarkConfig.textDarkColor : liveMarkConfig.textColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollContentView = PhotoPreviewContentView(type: .livePhoto)
        scrollContentView.delegate = self
        initView()
        addSubview(liveMarkView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contentView(requestSucceed contentView: PhotoPreviewContentView) {
        delegate?.cell(requestSucceed: self)
    }
    func contentView(requestFailed contentView: PhotoPreviewContentView) {
        delegate?.cell(requestFailed: self)
    }
    
    func contentView(livePhotoWillBeginPlayback contentView: PhotoPreviewContentView) {
        hideMark()
    }
    func contentView(livePhotoDidEndPlayback contentView: PhotoPreviewContentView) {
        showMark()
    }
    
    func showMark() {
        guard let liveMarkConfig = liveMarkConfig else {
            return
        }
//        #if HXPICKER_ENABLE_EDITOR
        if photoAsset.photoEdit != nil {
            return
        }
//        #endif
        if !liveMarkConfig.allowShow {
            return
        }
        if scrollContentView.livePhotoIsAnimating ||
            scrollContentView.isBacking ||
            statusBarShouldBeHidden { return }
        if let superView = superview, !(superView is UICollectionView) {
            return
        }
        if !liveMarkView.isHidden && liveMarkView.alpha == 1 { return }
        liveMarkView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.liveMarkView.alpha = 1
        }
    }
    func hideMark() {
        guard let liveMarkConfig = liveMarkConfig else {
            return
        }
//        #if HXPICKER_ENABLE_EDITOR
        if photoAsset.photoEdit != nil {
            return
        }
//        #endif
        if !liveMarkConfig.allowShow {
            return
        }
        if liveMarkView.isHidden { return }
        UIView.animate(withDuration: 0.25) {
            self.liveMarkView.alpha = 0
        } completion: { _ in
            if self.liveMarkView.alpha == 0 {
                self.liveMarkView.isHidden = true
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configLiveMark()
            }
        }
    }
}
