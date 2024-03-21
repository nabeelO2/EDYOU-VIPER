//
//  HX_ColorsBgAdapter.swift
//  ustories
//
//  Created by imac3 on 27/06/2023.
//

import Foundation

import UIKit

class HX_ColorsBgAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: UIViewController? {
        return collectionView.inputViewController?.viewContainingControllerHX() as? UIViewController
    }
    var didSelect: (_ bg: Background) -> Void
    
    
    struct Background {
        var colors = [UIColor]()
        var startPoint: CGPoint
        var endPoint: CGPoint
    }
    var backgrounds = [Background]()
    var selectedIndex = 0
    var selectedBorderColor = UIColor.green
    var selectedBorderWidth: CGFloat = 1.5
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, didSelect: @escaping (_ bg: Background) -> Void) {
        self.didSelect = didSelect
        
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(UINib(nibName: "ColorBgCellHX", bundle: nil), forCellWithReuseIdentifier: "ColorBgCellHX")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        backgrounds.append(Background(colors: ["FF7043".hx_Color, "FFD992".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["0088FF".hx_Color, "0092FF".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["FF8FB3".hx_Color, "C86DD7".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["20C9BD".hx_Color, "2054C9".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["F5317F".hx_Color, "FF7C6E".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["9DB2C7".hx_Color, "647B95".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["06D5FA".hx_Color, "18C5FB".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["464FF5".hx_Color, "E760C4".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["89BF1C".hx_Color, "FDC100".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["FFD600".hx_Color, "FF0100".hx_Color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
    }
    func selectedBackground() -> Background? {
        return backgrounds.objectHX(at: selectedIndex)
    }
    
}

// MARK: - Utility Methods
extension HX_ColorsBgAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension HX_ColorsBgAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorBgCellHX", for: indexPath) as! ColorBgCellHX
        cell.viewColor.colors = backgrounds[indexPath.row].colors
        cell.viewColor.startPoint = backgrounds[indexPath.row].startPoint
        cell.viewColor.endPoint = backgrounds[indexPath.row].endPoint
        cell.viewBgColor.layer.borderColor = indexPath.row == selectedIndex ? selectedBorderColor.cgColor : UIColor.clear.cgColor
        cell.viewBgColor.layer.borderWidth = selectedBorderWidth
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
        
        didSelect(backgrounds[indexPath.row])
    }
}
