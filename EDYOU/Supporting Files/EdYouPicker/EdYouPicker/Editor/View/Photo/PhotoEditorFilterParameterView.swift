//
//  PhotoEditorFilterParameterView.swift
//  EdYouPicker
//
//  Created by imac3 on 2022/10/3.
//

import UIKit

protocol PhotoEditorFilterParameterViewDelegate: AnyObject {
    func filterParameterView(
        _ filterParameterView: PhotoEditorFilterParameterView,
        didChanged model: PhotoEditorFilterParameterInfo
    )
}

class PhotoEditorFilterParameterView: UIView {
    
    enum `Type` {
        case filter
        case edit(type: PhotoEditorFilterEditModel.`Type`)
    }
    
    weak var delegate: PhotoEditorFilterParameterViewDelegate?
    
    lazy var bgView: UIVisualEffectView = {
        let visualEffect = UIBlurEffect.init(style: .dark)
        let view = UIVisualEffectView.init(effect: visualEffect)
        view.contentView.addSubview(titleLb)
        view.contentView.addSubview(tableView)
        return view
    }()
    
    lazy var titleLb: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PhotoEditorFilterParameterViewCell.self, forCellReuseIdentifier: "PhotoEditorFilterParameterViewCell")
        return tableView
    }()
    
    var type: `Type` = .filter
    
    var title: String? {
        didSet {
            titleLb.text = title
        }
    }
    
    var models: [PhotoEditorFilterParameterInfo] = [] {
        didSet {
            if models.count == 1 {
                tableView.hx_height = 60
                tableView.centerY = 25 + (hx_height - UIDevice.bottomMargin - 30) * 0.5
            }else {
                tableView.hx_height = CGFloat(models.count) * 40
                tableView.centerY = 30 + (hx_height - UIDevice.bottomMargin - 30) * 0.5
            }
            tableView.reloadData()
        }
    }
    
    let sliderColor: UIColor
    
    init(sliderColor: UIColor) {
        self.sliderColor = sliderColor
        super.init(frame: .zero)
        addSubview(bgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        titleLb.frame = .init(x: 0, y: 10, width: hx_width, height: 20)
        tableView.hx_width = hx_width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditorFilterParameterView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoEditorFilterParameterViewCell") as! PhotoEditorFilterParameterViewCell
        cell.model = models[indexPath.row]
        cell.sliderColor = sliderColor
        cell.sliderDidChanged = { [weak self] model in
            guard let self = self else { return }
            self.delegate?.filterParameterView(self, didChanged: model)
        }
        return cell
    }
}

extension PhotoEditorFilterParameterView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if models.count == 1 {
            return 60
        }
        return 40
    }
}

class PhotoEditorFilterParameterViewCell: UITableViewCell, ParameterSliderViewDelegate {
    lazy var titleLb: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var slider: ParameterSliderView = {
        let slider = ParameterSliderView()
        slider.value = 1
        slider.delegate = self
        return slider
    }()
    
    lazy var numberLb: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    func sliderView(_ sliderView: ParameterSliderView, didChangedValue value: CGFloat, state: ParameterSliderView.Event) {
        numberLb.text = String(Int(sliderView.value * 100))
        model?.value = Float(sliderView.value)
        if sliderView.value == 0 {
            model?.isNormal = true
        }else {
            model?.isNormal = false
        }
        if let model = model {
            sliderDidChanged?(model)
        }
    }
    
    var sliderDidChanged: ((PhotoEditorFilterParameterInfo) -> Void)?
    
    var model: PhotoEditorFilterParameterInfo? {
        didSet {
            guard let model = model else {
                return
            }
            slider.type = model.sliderType
            slider.setValue(CGFloat(model.value), isAnimation: false)
            numberLb.text = String(Int(slider.value * 100))
            titleLb.text = model.parameter.title
        }
    }
    
    var sliderColor: UIColor? {
        didSet {
            guard let sliderColor = sliderColor else {
                return
            }
            slider.progressColor = sliderColor.withAlphaComponent(0.3)
            slider.trackColor = sliderColor
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(titleLb)
        contentView.addSubview(slider)
        contentView.addSubview(numberLb)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLb.hx_x = 15 + UIDevice.leftMargin
        titleLb.hx_width = titleLb.textWidth
        titleLb.hx_height = hx_height
        
        if model?.parameter.title != nil {
            numberLb.frame = .init(x: hx_width - 10 - 40 - UIDevice.rightMargin, y: 0, width: 40, height: 20)
            numberLb.centerY = titleLb.centerY
            let sliderWidth: CGFloat = 200.0 / 375.0
            slider.hx_size = .init(width: UIScreen.main.bounds.width * sliderWidth, height: 20)
            slider.hx_x = numberLb.hx_x - 15 - slider.hx_width
            slider.centerY = titleLb.centerY
            
    //        if titleLb.frame.maxX > slider.x {
                titleLb.hx_width = slider.hx_x - titleLb.hx_x - 5
    //        }
        }else {
            numberLb.hx_width = 100
            numberLb.hx_height = numberLb.textHeight
            numberLb.centerX = hx_width * 0.5
            
            slider.hx_x = 30 + UIDevice.leftMargin
            slider.hx_width = hx_width - slider.hx_x - 30 - UIDevice.rightMargin
            slider.hx_height = 20
            slider.hx_y = numberLb.frame.maxY + 10
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ParameterSliderViewDelegate: AnyObject {
    func sliderView(
        _ sliderView: ParameterSliderView,
        didChangedValue value: CGFloat,
        state: ParameterSliderView.Event
    )
}

class ParameterSliderView: UIView {
    
    enum `Type`: Codable {
        case normal
        case center
    }
    
    enum Event {
        case touchDown
        case touchUpInSide
        case changed
    }
    
    weak var delegate: ParameterSliderViewDelegate?
    lazy var panGR: PhotoPanGestureRecognizer = {
        let pan = PhotoPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerClick(pan:)))
        return pan
    }()
    lazy var thumbView: UIImageView = {
        let imageSize = CGSize(width: 18, height: 18)
        let view = UIImageView(image: .image(for: .white, havingSize: imageSize, radius: 9))
        view.hx_size = imageSize
        return view
    }()
    var value: CGFloat = 0
    var thumbViewFrame: CGRect = .zero
    
    var didImpactFeedback = false

    var trackColor: UIColor? {
        didSet {
            trackView.backgroundColor = trackColor
            pointView.backgroundColor = trackColor
        }
    }
    
    lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1
        return view
    }()
    
    var progressColor: UIColor? {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var pointView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3
        view.isHidden = type == .normal
        return view
    }()
    
    var type: `Type` {
        didSet {
            pointView.isHidden = type == .normal
            layoutSubviews()
        }
    }
    
    init(type: `Type` = .normal) {
        self.type = type
        super.init(frame: .zero)
        addSubview(progressView)
        addSubview(trackView)
        addSubview(pointView)
        addSubview(thumbView)
        addGestureRecognizer(panGR)
    }
    
    func setValue(
        _ value: CGFloat,
        isAnimation: Bool
    ) {
        switch panGR.state {
        case .began, .changed, .ended:
            return
        default:
            break
        }
        if type == .normal {
            if value < 0 {
                self.value = 0
            }else if value > 1 {
                self.value = 1
            }else {
                self.value = value
            }
        }else {
            if value < -1 {
                self.value = -1
            }else if value > 1 {
                self.value = 1
            }else {
                self.value = value
            }
        }
        let currentWidth = self.value * hx_width
        if isAnimation {
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [
                    .curveLinear,
                    .allowUserInteraction
                ]
            ) {
                if self.type == .normal {
                    self.thumbView.centerX = self.hx_width * self.value
                    self.trackView.hx_width = currentWidth
                }else {
                    self.trackView.hx_width = self.hx_width * 0.5 * value
                    if value >= 0 {
                        self.trackView.hx_x = self.hx_width * 0.5
                    }else {
                        self.trackView.hx_x = self.hx_width * 0.5 - self.trackView.hx_width
                    }
                    self.thumbView.centerX = self.hx_width * 0.5 + self.hx_width * 0.5 * value
                }
            }
        }else {
            if type == .normal {
                thumbView.centerX = hx_width * value
                trackView.hx_width = currentWidth
            }else {
                trackView.hx_width = hx_width * 0.5 * value
                if value >= 0 {
                    trackView.hx_x = hx_width * 0.5
                }else {
                    trackView.hx_x = hx_width * 0.5 - trackView.hx_width
                }
                thumbView.centerX = hx_width * 0.5 + hx_width * 0.5 * value
            }
        }
    }
    
    @objc func panGestureRecognizerClick(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            let point = pan.location(in: self)
            let rect = CGRect(
                x: thumbView.hx_x - 20,
                y: thumbView.hx_y - 20,
                width: thumbView.hx_width + 40,
                height: thumbView.hx_height + 40
            )
            if !rect.contains(point) {
                pan.isEnabled = false
                pan.isEnabled = true
                return
            }
            if thumbViewFrame.equalTo(.zero) {
                thumbViewFrame = thumbView.frame
            }
            delegate?.sliderView(self, didChangedValue: value, state: .touchDown)
        case .changed:
            let specifiedPoint = pan.translation(in: self)
            var rect = thumbViewFrame
            rect.origin.x += specifiedPoint.x
            if rect.midX < 0 {
                rect.origin.x = -thumbView.hx_width * 0.5
            }
            if rect.midX > hx_width {
                rect.origin.x = hx_width - thumbView.hx_width * 0.5
            }
            if type == .normal {
                value = rect.midX / hx_width
                if (value == 0 || value == 1) && !didImpactFeedback {
                    let shake = UIImpactFeedbackGenerator(style: .light)
                    shake.prepare()
                    shake.impactOccurred()
                    didImpactFeedback = true
                }else {
                    if value != 0 && value != 1 {
                        didImpactFeedback = false
                    }
                }
                trackView.hx_width = hx_width * value
            }else {
                let midWidth = hx_width * 0.5
                if rect.midX >= hx_width * 0.5 {
                    value = (rect.midX - midWidth) / midWidth
                }else {
                    value = -(1 - rect.midX / midWidth)
                }
                if value < 0.015 && value > -0.015 {
                    rect.origin.x = hx_width * 0.5 - rect.width * 0.5
                    value = 0
                }
                trackView.hx_width = hx_width * 0.5 + hx_width * 0.5 * value
                if value >= 0 {
                    trackView.hx_x = hx_width * 0.5
                }else {
                    trackView.hx_x = hx_width * 0.5 - trackView.hx_width
                }
                if ((value < 0.015 && value > -0.015) || value == 1 || value == -1) && !didImpactFeedback {
                    let shake = UIImpactFeedbackGenerator(style: .medium)
                    shake.prepare()
                    shake.impactOccurred()
                    didImpactFeedback = true
                }else {
                    if (value >= 0.015 || value <= -0.015) && value != 1 && value != -1 {
                        didImpactFeedback = false
                    }
                }
            }
            thumbView.frame = rect
            delegate?.sliderView(self, didChangedValue: value, state: .changed)
        case .cancelled, .ended, .failed:
            thumbViewFrame = .zero
            delegate?.sliderView(self, didChangedValue: value, state: .touchUpInSide)
        default:
            break
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = CGRect(
            x: thumbView.hx_x - 15,
            y: thumbView.hx_y - 15,
            width: thumbView.hx_width + 30,
            height: thumbView.hx_height + 30
        )
        if rect.contains(point) {
            return thumbView
        }
        return super.hitTest(point, with: event)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = CGRect(x: 0, y: (hx_height - 3) * 0.5, width: hx_width, height: 3)
        trackView.frame = CGRect(x: 0, y: (hx_height - 3) * 0.5, width: hx_width * value, height: 3)
        thumbView.centerY = hx_height * 0.5
        if type == .normal {
            thumbView.centerX = hx_width * value
        }else {
            trackView.hx_width = hx_width * 0.5 * value
            if value >= 0 {
                trackView.hx_x = hx_width * 0.5
            }else {
                trackView.hx_x = hx_width * 0.5 - trackView.hx_width
            }
            thumbView.centerX = hx_width * 0.5 + hx_width * 0.5 * value
            pointView.hx_size = .init(width: 6, height: 6)
            pointView.center = progressView.center
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
