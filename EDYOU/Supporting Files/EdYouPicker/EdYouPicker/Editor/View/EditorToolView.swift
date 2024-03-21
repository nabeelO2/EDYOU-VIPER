//
//  EditorToolView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/9.
//

import UIKit

protocol EditorToolViewDelegate: AnyObject {
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolOptions)
    func toolView(didFinishButtonClick toolView: EditorToolView, forIndex : Int)
}

public class EditorToolScrollView: UICollectionView {
    public override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}

public class EditorToolView: UIView {
    weak var delegate: EditorToolViewDelegate?
    var config: EditorToolViewConfiguration
    
    let background : UIColor = UIColor.init(red: 0.027450980392156862, green: 0.75686274509803919, blue: 0.37647058823529411, alpha: 1)
    
    public lazy var maskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(false)
        return layer
    }()
    
    lazy var shadeView: UIView = {
        let view = UIView()
        view.addSubview(collectionView)
//        view.layer.mask = shadeMaskLayer
//        view.backgroundColor = .red
        return view
    }()
    
    lazy var shadeMaskLayer: CAGradientLayer = {
        let maskLayer = CAGradientLayer.init()
        maskLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 1)
        maskLayer.endPoint = CGPoint(x: 1, y: 1)
        maskLayer.locations = [0.95, 1.0]
        return maskLayer
    }()
    
    public lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 40, height: 40)
        return flowLayout
    }()
    
    public lazy var collectionView: EditorToolScrollView = {
        let collectionView = EditorToolScrollView(
            frame: CGRect(x: 0, y: 8, width: 0, height: 50),
            collectionViewLayout: flowLayout
        )
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(EditorToolViewCell.self, forCellWithReuseIdentifier: "EditorToolViewCellID")
        return collectionView
    }()
    
    func reloadContentInset() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12 + UIDevice.leftMargin, bottom: 0, right: 12)
    }
    
    public lazy var finishButton: UIButton = {
        let finishButton = UIButton.init(type: .custom)
        finishButton.setTitle("Publish".localized, for: .normal)
        finishButton.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        finishButton.layer.cornerRadius = 3
        finishButton.layer.masksToBounds = true
        finishButton.addTarget(self, action: #selector(didFinishButtonClick(button:)), for: .touchUpInside)
        return finishButton
    }()
    
    @objc func didFinishButtonClick(button: UIButton){
        delegate?.toolView(didFinishButtonClick: self, forIndex: 0)
    }
    var stretchMask: Bool = false
    var currentSelectedIndexPath: IndexPath?
    var musicCellShowBox: Bool = false
    
    init(config: EditorToolViewConfiguration) {
        self.config = config
        super.init(frame: .zero)
//        layer.addSublayer(maskLayer)
        addSubview(shadeView)
       // addSubview(finishButton)
        configColor()
    }
    func configColor() {
        let isDark = PhotoManager.isDark
        
        finishButton.setTitleColor(
            isDark ? backgroundColor : background,
            for: .normal
        )
        
        finishButton.setBackgroundImage(
            UIImage.image(
                for: isDark ? config.finishButtonDarkBackgroundColor : background,
                havingSize: .zero
            ),
            for: .normal
        )
    }
    func deselected() {
        if let indexPath = currentSelectedIndexPath {
            let cell = collectionView.cellForItem(at: indexPath) as? EditorToolViewCell
            cell?.isSelectedImageView = false
            currentSelectedIndexPath = nil
        }
    }
    
    func selected(indexPath: IndexPath) {
        deselected()
        let cell = collectionView.cellForItem(at: indexPath) as? EditorToolViewCell
        cell?.isSelectedImageView = true
        currentSelectedIndexPath = indexPath
    }
    
    func reloadMusic(isSelected: Bool) {
        musicCellShowBox = isSelected
        for (index, option) in config.toolOptions.enumerated() where
            option.type == .music {
            collectionView.reloadItems(
                at: [
                    IndexPath(item: index, section: 0)
                ]
            )
            return
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        maskLayer.frame = CGRect(
            x: 0,
            y: stretchMask ? -70 : -10,
            width: hx_width,
            height: stretchMask ? hx_height + 70 : hx_height + 10
        )
//        var finishWidth = (finishButton.currentTitle?.width(
//                            ofFont: finishButton.titleLabel!.font,
//                            maxHeight: 33) ?? 0) + 20
//
//        if finishWidth < 60 {
//            finishWidth = 60
//        }
//        finishButton.width = finishWidth
//        finishButton.height = 33
//        finishButton.x = width - finishButton.width - 12 - UIDevice.rightMargin
//        finishButton.centerY = 25
        
        shadeView.frame = CGRect(
            x: 0,
            y: 0,
            width: hx_width,
            height: 44
        )
        collectionView.frame = shadeView.bounds
        shadeMaskLayer.frame = CGRect(x: 0, y: 0, width: shadeView.hx_width, height: shadeView.hx_height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorToolView: UICollectionViewDataSource, UICollectionViewDelegate, EditorToolViewCellDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        config.toolOptions.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EditorToolViewCellID",
            for: indexPath
        ) as! EditorToolViewCell
        let model = config.toolOptions[indexPath.item]
        cell.delegate = self
        cell.boxColor = background//config.musicSelectedColor
        if model.type == .music {
            cell.showBox = musicCellShowBox
        }else {
            cell.showBox = false
        }
        cell.selectedColor = background//config.toolSelectedColor
        cell.model = model
        if model.type == .graffiti || model.type == .mosaic {
            if let selectedIndexPath = currentSelectedIndexPath,
               selectedIndexPath.item == indexPath.item {
                cell.isSelectedImageView = true
            }else {
                cell.isSelectedImageView = false
            }
        }else {
            cell.isSelectedImageView = false
        }
//        cell.btnBackgroundView.backgroundColor = .white
//        cell.button.backgroundColor = .red
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func toolViewCell(didClick cell: EditorToolViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let option = config.toolOptions[indexPath.item]
        if option.type == .graffiti || option.type == .mosaic {
            if let selectedIndexPath = currentSelectedIndexPath,
               selectedIndexPath.item == indexPath.item {
                deselected()
            }else {
                selected(indexPath: indexPath)
            }
        }
        delegate?.toolView(self, didSelectItemAt: option)
    }
    

}
