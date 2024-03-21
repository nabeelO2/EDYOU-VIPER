//
//  PickerAddTextCell.swift
//  ustories
//
//  Created by imac3 on 12/06/2023.
//

import UIKit

class PickerAddTextCell: UICollectionViewCell {
    
    
    lazy var backgroundViewView: HX_GradientView = {
        let view = HX_GradientView()
        let firstColor = UIColor(red: 0.922, green: 0.706, blue: 0.294, alpha: 1)
        let secColor = UIColor(red: 0.855, green: 0.392, blue: 0.361, alpha: 1)
        view.colors = [firstColor, secColor]
        view.startPoint = .zero
        
        return view
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var config: PhotoListConfiguration.AddTextCell? {
        didSet {
            configProperty()
        }
    }
    var allowPreview = true
    override init(frame: CGRect) {
        super.init(frame: frame)
       // contentView.addSubview(captureView)
        contentView.addSubview(backgroundViewView)
        contentView.addSubview(titleLbl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configProperty() {
        //        imageView.image = UIImage.image(for: PhotoManager.isDark ?   config?.cameraDarkImageName :  config?.cameraImageName)
        
        backgroundColor = .red //PhotoManager.isDark ? config?.backgroundDarkColor : config?.backgroundColor
        //        imageView.size = imageView.image?.size ?? .zero
        //        self.titleLbl.text = "plain text"
        
        titleLbl.text = config?.title?.localized
//        let isDark = PhotoManager.isDark
//        backgroundColor = isDark ? config?.backgroundDarkColor : config?.backgroundColor
        titleLbl.textColor = config?.titleColor
        titleLbl.font = config?.titleFont
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundViewView.frame = self.bounds
        
        titleLbl.center = CGPoint(x: hx_width * 0.5, y: hx_height * 0.5)
        titleLbl.hx_x = 0
        titleLbl.hx_y = (hx_height) * 0.5
        titleLbl.hx_width = hx_width
        titleLbl.hx_height = titleLbl.textHeight
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configProperty()
            }
        }
    }
    deinit {
        
    }
}
