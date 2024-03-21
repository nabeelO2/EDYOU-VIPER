//
//  DeniedAuthorizationView.swift
//  EdYouPickerExample
//
//  Created by imac3 on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
 
class DeniedAuthorizationView: UIView {
    
    let config: NotAuthorizedConfiguration
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar.init()
        navigationBar.setBackgroundImage(
            UIImage.image(
                for: UIColor.clear,
                havingSize: CGSize.zero
            ),
            for: UIBarMetrics.default
        )
        navigationBar.shadowImage = UIImage.init()
        let navigationItem = UINavigationItem.init()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: closeBtn)
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.hx_size = CGSize(width: 50, height: 40)
        closeBtn.addTarget(self, action: #selector(didCloseClick), for: .touchUpInside)
        closeBtn.contentHorizontalAlignment = .left
        return closeBtn
    }()
    
    lazy var titleLb: UILabel = {
        let titleLb = UILabel.init()
        titleLb.textAlignment = .center
        titleLb.numberOfLines = 0
        return titleLb
    }()
    
    lazy var subTitleLb: UILabel = {
        let subTitleLb = UILabel.init()
        subTitleLb.textAlignment = .center
        subTitleLb.numberOfLines = 0
        return subTitleLb
    }()
    
    lazy var jumpBtn: UIButton = {
        let jumpBtn = UIButton.init(type: .custom)
        jumpBtn.layer.cornerRadius = 5
        jumpBtn.addTarget(self, action: #selector(jumpSetting), for: .touchUpInside)
        return jumpBtn
    }()
    
    init(config: NotAuthorizedConfiguration) {
        self.config = config
        super.init(frame: CGRect.zero)
        configView()
    }
    
    func configView() {
        if !config.hiddenCloseButton {
            addSubview(navigationBar)
        }
        addSubview(titleLb)
        addSubview(subTitleLb)
        addSubview(jumpBtn)
        
        titleLb.text = "Can't access photos in album".localized
        titleLb.font = UIFont.semiboldPingFang(ofSize: 20)
        
        subTitleLb.text = "Currently no photo access，System settings recommended，\nAllow access to all photos in photos.".localized
        subTitleLb.font = UIFont.regularPingFang(ofSize: 17)
        
        jumpBtn.setTitle("Settings".localized, for: .normal)
        jumpBtn.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        
        configColor()
    }
    func configColor() {
        let closeButtonImageName = config.closeButtonImageName
        let closeButtonDarkImageName = config.closeButtonDarkImageName
        let isDark = PhotoManager.isDark
        closeBtn.setImage(UIImage.image(for: isDark ? closeButtonDarkImageName : closeButtonImageName), for: .normal)
        backgroundColor = isDark ? config.darkBackgroundColor : config.backgroundColor
        titleLb.textColor = isDark ? config.titleDarkColor : config.titleColor
        subTitleLb.textColor = isDark ? config.darkSubTitleColor : config.subTitleColor
        jumpBtn.backgroundColor = isDark ? config.jumpButtonDarkBackgroundColor : config.jumpButtonBackgroundColor
        jumpBtn.setTitleColor(isDark ? config.jumpButtonTitleDarkColor : config.jumpButtonTitleColor, for: .normal)
    }
    @objc func didCloseClick() {
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    @objc func jumpSetting() {
        PhotoTools.openSettingsURL()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var barHeight: CGFloat = 0
        var barY: CGFloat = 0
        if let pickerController = viewController as? PhotoPickerController {
            barHeight = pickerController.navigationBar.hx_height
            if pickerController.modalPresentationStyle == .fullScreen {
                barY = UIDevice.statusBarHeight
            }
        }
        navigationBar.frame = CGRect(x: 0, y: barY, width: hx_width, height: barHeight)
        
        let titleHeight = titleLb.text?.height(ofFont: titleLb.font, maxWidth: hx_width) ?? 0
        titleLb.frame = CGRect(x: 0, y: 0, width: hx_width, height: titleHeight)
        
        let subTitleHeight = subTitleLb.text?.height(ofFont: subTitleLb.font, maxWidth: hx_width - 40) ?? 0
        let subTitleY: CGFloat
        if barHeight == 0 {
            subTitleY = hx_height / 2 - subTitleHeight
        }else {
            subTitleY = hx_height / 2 - subTitleHeight - 30 - UIDevice.topMargin
        }
        subTitleLb.frame = CGRect(
            x: 20,
            y: subTitleY,
            width: hx_width - 40,
            height: subTitleHeight
        )
        titleLb.hx_y = subTitleLb.hx_y - 15 - titleHeight
        
        let jumpBtnBottomMargin: CGFloat = UIDevice.isProxy() ? 120 : 50
        var jumpBtnWidth = (jumpBtn.currentTitle?.width(ofFont: jumpBtn.titleLabel!.font, maxHeight: 40) ?? 0 ) + 10
        if jumpBtnWidth < 150 {
            jumpBtnWidth = 150
        }
        let jumpY: CGFloat
        if barHeight == 0 {
            jumpY = hx_height - UIDevice.bottomMargin - 50
        }else {
            jumpY = hx_height - UIDevice.bottomMargin - 40 - jumpBtnBottomMargin
        }
        jumpBtn.frame = CGRect(
            x: 0,
            y: jumpY,
            width: jumpBtnWidth,
            height: 40
        )
        jumpBtn.centerX = hx_width * 0.5
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configColor()
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
