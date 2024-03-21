//
//  EditorStickerTrashView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/7/22.
//

import UIKit

class EditorStickerTrashView: UIView {
    lazy var bgView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()
    
    lazy var redView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = "FF5653".hx_Color
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: "hx_editor_photo_trash_close".image)
        imageView.hx_size = imageView.image?.size ?? .zero
        return imageView
    }()
    
    lazy var textLb: UILabel = {
        let textLb = UILabel()
        textLb.text = "Drag here to delete".localized
        textLb.textColor = .white
        textLb.textAlignment = .center
        textLb.font = UIFont.systemFont(ofSize: 14)
        textLb.adjustsFontSizeToFitWidth = true
        return textLb
    }()
    
    var inArea: Bool = false {
        didSet {
            bgView.isHidden = inArea
            redView.isHidden = !inArea
            imageView.image = inArea ? "hx_editor_photo_trash_open".image : "hx_editor_photo_trash_close".image
            imageView.hx_size = imageView.image?.size ?? .zero
            imageView.centerX = hx_width * 0.5
            textLb.text = inArea ? "Let go to delete".localized : "Drag here to delete".localized
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgView)
        addSubview(redView)
        addSubview(imageView)
        addSubview(textLb)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        redView.frame = bounds
        imageView.hx_y = hx_height * 0.5 - imageView.hx_height
        imageView.centerX = hx_width * 0.5
        
        textLb.hx_y = hx_height * 0.5 + 8
        textLb.hx_x = 5
        textLb.hx_width = hx_width - 10
        textLb.hx_height = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
