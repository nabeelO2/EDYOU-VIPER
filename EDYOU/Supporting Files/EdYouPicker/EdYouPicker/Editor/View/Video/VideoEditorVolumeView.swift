//
//  VideoEditorVolumeView.swift
//  EdYouPicker
//
//  Created by imac3 on 2022/1/11.
//

import UIKit

protocol VideoEditorVolumeViewDelegate: AnyObject {
    func volumeView(didChanged volumeView: VideoEditorVolumeView)
}

class VideoEditorVolumeView: UIView {
    weak var delegate: VideoEditorVolumeViewDelegate?
    lazy var bgMaskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(false)
        return layer
    }()
    lazy var bgView: UIVisualEffectView = {
        let visualEffect = UIBlurEffect.init(style: .light)
        let view = UIVisualEffectView.init(effect: visualEffect)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    lazy var musicTitleLb: UILabel = {
        let label = UILabel()
        label.text = "Soundtrack".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var musicVolumeSlider: UISlider = {
        let slider = UISlider()
        let image = UIImage.image(for: .white, havingSize: .init(width: 15, height: 15), radius: 7.5)
        slider.setThumbImage(image, for: .normal)
        slider.setThumbImage(image, for: .highlighted)
        slider.value = 1
        slider.addTarget(
            self,
            action: #selector(sliderDidChanged(_:)),
            for: .valueChanged
        )
        return slider
    }()
    
    lazy var musicVolumeNumberLb: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var originalTitleLb: UILabel = {
        let label = UILabel()
        label.text = "Original sound".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var originalVolumeSlider: UISlider = {
        let slider = UISlider()
        let image = UIImage.image(for: .white, havingSize: .init(width: 15, height: 15), radius: 7.5)
        slider.setThumbImage(image, for: .normal)
        slider.setThumbImage(image, for: .highlighted)
        slider.value = 1
        slider.addTarget(
            self,
            action: #selector(sliderDidChanged(_:)),
            for: .valueChanged
        )
        return slider
    }()
    
    lazy var originalVolumeNumberLb: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    @objc
    func sliderDidChanged(_ slider: UISlider) {
        if slider == musicVolumeSlider {
            musicVolume = slider.value
        }else {
            originalVolume = slider.value
        }
        delegate?.volumeView(didChanged: self)
    }
    var hasOriginalSound: Bool = true {
        didSet {
            originalTitleLb.alpha = hasOriginalSound ? 1 : 0.3
            originalVolumeSlider.alpha = hasOriginalSound ? 1 : 0.3
            originalVolumeSlider.isUserInteractionEnabled = hasOriginalSound
            originalVolumeNumberLb.alpha = hasOriginalSound ? 1 : 0.3
        }
    }
    
    var originalVolume: Float = 1 {
        didSet {
            if oldValue == originalVolume { return }
            originalVolumeSlider.value = originalVolume
            originalVolumeNumberLb.text = String(Int(originalVolume * 100))
        }
    }
    
    var musicVolume: Float = 1 {
        didSet {
            if oldValue == musicVolume { return }
            musicVolumeSlider.value = musicVolume
            musicVolumeNumberLb.text = String(Int(musicVolume * 100))
        }
    }
    
    init(_ color: UIColor) {
        super.init(frame: .zero)
        layer.addSublayer(bgMaskLayer)
        addSubview(bgView)
        addSubview(musicTitleLb)
        addSubview(musicVolumeSlider)
        musicVolumeSlider.minimumTrackTintColor = color
        addSubview(musicVolumeNumberLb)
        addSubview(originalTitleLb)
        addSubview(originalVolumeSlider)
        originalVolumeSlider.minimumTrackTintColor = color
        addSubview(originalVolumeNumberLb)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgMaskLayer.frame = CGRect(
            x: -UIDevice.leftMargin - 15,
            y: -20,
            width: hx_width + UIDevice.leftMargin + UIDevice.rightMargin + 30,
            height: hx_height + 40 + UIDevice.bottomMargin
        )
        bgView.frame = bounds
        
        musicTitleLb.hx_x = 30
        musicTitleLb.hx_y = 30
        musicTitleLb.hx_width = musicTitleLb.textWidth
        musicTitleLb.hx_height = musicTitleLb.textHeight
        
        musicVolumeNumberLb.frame = .init(x: hx_width - 10 - 50, y: 0, width: 50, height: 20)
        musicVolumeNumberLb.centerY = musicTitleLb.centerY
        
        let sliderWidth: CGFloat = 130.0 / 375.0
        musicVolumeSlider.hx_size = .init(width: UIScreen.main.bounds.width * sliderWidth, height: 20)
        musicVolumeSlider.hx_x = musicVolumeNumberLb.hx_x - 15 - musicVolumeSlider.hx_width
        musicVolumeSlider.centerY = musicTitleLb.centerY
        
        if musicTitleLb.frame.maxX > musicVolumeSlider.hx_x {
            musicTitleLb.hx_width = musicVolumeSlider.hx_x - musicTitleLb.hx_x - 5
        }
        
        originalTitleLb.hx_x = musicTitleLb.hx_x
        originalTitleLb.hx_y = musicTitleLb.frame.maxY + 30
        originalTitleLb.hx_width = originalTitleLb.textWidth
        originalTitleLb.hx_height = originalTitleLb.textHeight
        
        originalVolumeNumberLb.frame = .init(x: hx_width - 10 - 50, y: 0, width: 50, height: 20)
        originalVolumeNumberLb.centerY = originalTitleLb.centerY
        
        originalVolumeSlider.hx_size = musicVolumeSlider.hx_size
        originalVolumeSlider.hx_x = originalVolumeNumberLb.hx_x - 15 - originalVolumeSlider.hx_width
        originalVolumeSlider.centerY = originalTitleLb.centerY
        
        if originalTitleLb.frame.maxX > originalVolumeSlider.hx_x {
            originalTitleLb.hx_width = originalVolumeSlider.hx_x - originalTitleLb.hx_x - 5
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
