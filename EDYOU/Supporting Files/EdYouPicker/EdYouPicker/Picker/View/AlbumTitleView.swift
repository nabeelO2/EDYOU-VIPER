//
//  AlbumTitleView.swift
//  EdYouPickerExample
//
//  Created by imac3 on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

class AlbumTitleView: UIControl {
   
   var config: AlbumTitleViewConfiguration
   
   lazy var contentView: UIView = {
       let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
       contentView.layer.cornerRadius = 15
       contentView.layer.masksToBounds = true
       contentView.isUserInteractionEnabled = false
       return contentView
   }()
   
   var title: String? {
       didSet {
           if title == nil {
               title = "Album".localized
           }
           titleLb.text = title
           updateTitleFrame()
       }
   }
   func updateTitleFrame() {
       var titleWidth = title?.width(ofFont: titleLb.font, maxHeight: hx_height) ?? 0
       if titleWidth > hx_width - 40 {
           titleWidth = hx_width - 45
       }
       UIView.animate(withDuration: 0.25) {
           self.titleLb.hx_width = titleWidth
           self.arrowView.hx_x = self.titleLb.frame.maxX + 5
           self.contentView.hx_width = self.arrowView.frame.maxX + 5
           self.contentView.centerX = self.hx_width * 0.5
       }
   }
   func updateViewFrame() {
       hx_size = CGSize(width: UIScreen.main.bounds.size.width * 0.5, height: 30)
       updateTitleFrame()
   }
   var titleColor: UIColor? {
       didSet {
           titleLb.textColor = titleColor
       }
   }
   
   private lazy var titleLb: UILabel = {
        let text = "Album".localized
        let font = UIFont.semiboldPingFang(ofSize: 18)
        let titleLb = UILabel(
            frame: CGRect(
                x: 10,
                y: 0,
                width: text.width(ofFont: font, maxHeight: hx_height),
                height: hx_height
            )
        )
        titleLb.text = text
        titleLb.font = font
        titleLb.textAlignment = .center
        return titleLb
   }()
   
   lazy var arrowView: ArrowView = {
       let arrowView = ArrowView(
        frame: CGRect(
            x: titleLb.frame.maxX + 5,
            y: 0,
            width: 20,
            height: 20
        ),
        config: self.config.arrow
       )
       
       return arrowView
   }()
   
   init(config: AlbumTitleViewConfiguration) {
       self.config = config
       super.init(frame: CGRect.zero)
       hx_size = CGSize(width: UIScreen.main.bounds.size.width * 0.5, height: 30)
       contentView.addSubview(titleLb)
       contentView.addSubview(arrowView)
       addSubview(contentView)
       configColor()
   }
   
   override func layoutSubviews() {
       super.layoutSubviews()
       titleLb.hx_height = hx_height
       arrowView.centerY = titleLb.centerY
       contentView.hx_height = hx_height
   }
   
   func configColor() {
       contentView.backgroundColor = PhotoManager.isDark ? config.backgroudDarkColor : config.backgroundColor
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
