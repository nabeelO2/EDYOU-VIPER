//
//  PhotoEditorBrushColorView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/6/12.
//

import UIKit

protocol PhotoEditorBrushColorViewDelegate: AnyObject {
    func brushColorView(
        _ colorView: PhotoEditorBrushColorView,
        changedColor colorHex: String
    )
    func brushColorView(
        _ colorView: PhotoEditorBrushColorView,
        changedColor color: UIColor
    )
    func brushColorView(
        didUndoButton colorView: PhotoEditorBrushColorView
    )
}

public class PhotoEditorBrushColorView: UIView {
    weak var delegate: PhotoEditorBrushColorViewDelegate?
    let config: EditorBrushConfiguration
    let brushColors: [String]
    
    lazy var shadeView: UIView = {
        let view = UIView.init()
        view.addSubview(collectionView)
        view.layer.mask = maskLayer
        return view
    }()
    
    lazy var maskLayer: CAGradientLayer = {
        let maskLayer = CAGradientLayer.init()
        maskLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 1)
        maskLayer.endPoint = CGPoint(x: 1, y: 1)
        maskLayer.locations = [0.925, 1.0]
        return maskLayer
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.itemSize = CGSize(width: 37, height: 37)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(
            PhotoEditorBrushColorViewCell.self,
            forCellWithReuseIdentifier: "PhotoEditorBrushColorViewCellID"
        )
        return collectionView
    }()
    
    var canUndo: Bool = false {
        didSet {
            undoButton.isEnabled = canUndo
        }
    }
    
    lazy var undoButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.setImage(UIImage.image(for: "hx_editor_brush_repeal"), for: .normal)
        button.addTarget(self, action: #selector(didUndoClick(button:)), for: .touchUpInside)
        button.tintColor = .white
        button.isEnabled = false
        return button
    }()
    
    @objc func didUndoClick(button: UIButton) {
        delegate?.brushColorView(didUndoButton: self)
    }
    
    var canAddCustom: Bool {
        if #available(iOS 14.0, *), config.addCustomColor {
            return true
        }else {
            return false
        }
    }
    lazy var customColor: PhotoEditorBrushCustomColor = {
        let custom = PhotoEditorBrushCustomColor(
            color: config.customDefaultColor
        )
        return custom
    }()
    
    init(config: EditorBrushConfiguration) {
        self.config = config
        self.brushColors = config.colors
        super.init(frame: .zero)
        addSubview(shadeView)
        addSubview(undoButton)
        collectionView.selectItem(
            at: IndexPath(
                item: config.defaultColorIndex,
                section: 0
            ),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let cHeight: CGFloat = 60
        shadeView.frame = CGRect(
            x: 0,
            y: 5,
            width: hx_width,
            height: cHeight
        )
        collectionView.frame = shadeView.bounds
        maskLayer.frame = CGRect(x: 0, y: 0, width: shadeView.hx_width - 50 - UIDevice.rightMargin, height: shadeView.hx_height)
        flowLayout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 12 + UIDevice.leftMargin,
            bottom: 0,
            right: cHeight + UIDevice.rightMargin
        )
        undoButton.frame = CGRect(
            x: hx_width - UIDevice.rightMargin - cHeight,
            y: shadeView.hx_y,
            width: cHeight,
            height: cHeight
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditorBrushColorView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if canAddCustom {
            return brushColors.count + 1
        }else {
            return brushColors.count
        }
    }
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoEditorBrushColorViewCellID",
            for: indexPath
        ) as! PhotoEditorBrushColorViewCell
        if canAddCustom && indexPath.item == brushColors.count {
            cell.customColor = customColor
        }else {
            cell.colorHex = brushColors[indexPath.item]
        }
        return cell
    }
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        if canAddCustom {
            if indexPath.item == brushColors.count {
                if #available(iOS 14.0, *) {
                    didSelectCustomColor(customColor.color)
                    if !customColor.isFirst && !customColor.isSelected {
                        customColor.isSelected = true
                        return
                    }
                    let vc = UIColorPickerViewController()
                    vc.delegate = self
                    vc.selectedColor = customColor.color
                    viewController?.present(vc, animated: true, completion: nil)
                    customColor.isFirst = false
                    customColor.isSelected = true
                }
                return
            }
            customColor.isSelected = false
        }
        delegate?.brushColorView(
            self,
            changedColor: brushColors[indexPath.item]
        )
    }
}

@available(iOS 14.0, *)
extension PhotoEditorBrushColorView: UIColorPickerViewControllerDelegate {
    public func colorPickerViewControllerDidSelectColor(
        _ viewController: UIColorPickerViewController
    ) {
        if #available(iOS 15.0, *) {
            return
        }
        didSelectCustomColor(viewController.selectedColor)
    }
    @available(iOS 15.0, *)
    public func colorPickerViewController(
        _ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool
    ) {
        didSelectCustomColor(color)
    }
    func didSelectCustomColor(_ color: UIColor) {
        customColor.color = color
        let cell = collectionView.cellForItem(
            at: .init(item: brushColors.count, section: 0)
        ) as? PhotoEditorBrushColorViewCell
        cell?.customColor = customColor
        delegate?.brushColorView(
            self,
            changedColor: customColor.color
        )
    }
}

class PhotoEditorBrushColorViewCell: UICollectionViewCell {
    lazy var colorBgView: UIView = {
        let view = UIView.init()
        view.hx_size = CGSize(width: 22, height: 22)
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        view.addSubview(imageView)
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: "hx_editor_brush_color_custom".image)
        view.isHidden = true
        
        let bgLayer = CAShapeLayer()
        bgLayer.contentsScale = UIScreen.main.scale
        bgLayer.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        bgLayer.fillColor = UIColor.white.cgColor
        let bgPath = UIBezierPath(
            roundedRect: CGRect(x: 1.5, y: 1.5, width: 19, height: 19),
            cornerRadius: 19 * 0.5
        )
        bgLayer.path = bgPath.cgPath
        view.layer.addSublayer(bgLayer)

        let maskLayer = CAShapeLayer()
        maskLayer.contentsScale = UIScreen.main.scale
        maskLayer.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        let maskPath = UIBezierPath(rect: bgLayer.bounds)
        maskPath.append(
            UIBezierPath(
                roundedRect: CGRect(x: 3, y: 3, width: 16, height: 16),
                cornerRadius: 8
            ).reversing()
        )
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        return view
    }()
    
    lazy var colorView: UIView = {
        let view = UIView.init()
        view.hx_size = CGSize(width: 16, height: 16)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    var colorHex: String! {
        didSet {
            imageView.isHidden = true
            guard let colorHex = colorHex else { return }
            let color = colorHex.hx_Color
            if color.isWhite {
                colorBgView.backgroundColor = "#dadada".hx_Color
            }else {
                colorBgView.backgroundColor = .white
            }
            colorView.backgroundColor = color
        }
    }
    
    var customColor: PhotoEditorBrushCustomColor? {
        didSet {
            guard let customColor = customColor else {
                return
            }
            imageView.isHidden = false
            colorView.backgroundColor = customColor.color
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.colorBgView.transform = self.isSelected ? .init(scaleX: 1.25, y: 1.25) : .identity
                self.colorView.transform = self.isSelected ? .init(scaleX: 1.3, y: 1.3) : .identity
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorBgView)
        contentView.addSubview(colorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorBgView.center = CGPoint(x: hx_width / 2, y: hx_height / 2)
        imageView.frame = colorBgView.bounds
        colorView.center = CGPoint(x: hx_width / 2, y: hx_height / 2)
    }
}

struct PhotoEditorBrushCustomColor {
    var isFirst: Bool = true
    var isSelected: Bool = false
    var color: UIColor
}
