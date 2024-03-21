//
//  
//  ColorsBgAdapter.swift
//  EDYOU
//
//  Created by  Mac on 14/09/2021.
//
//

import UIKit

class ColorsBgAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: NewPostController? {
        return collectionView.viewContainingController() as? NewPostController
    }
    var didSelect: (_ bg: Background) -> Void
    
    
    struct Background {
        var colors = [UIColor]()
        var startPoint: CGPoint
        var endPoint: CGPoint
    }
    var backgrounds = [Background]()
    var selectedIndex = 0
    var selectedBorderColor = R.color.buttons_green() ?? .green
    var selectedBorderWidth: CGFloat = 1.5
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, didSelect: @escaping (_ bg: Background) -> Void) {
        self.didSelect = didSelect
        
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(ColorBgCell.nib, forCellWithReuseIdentifier: ColorBgCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        backgrounds.append(Background(colors: ["FF7043".color, "FFD992".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["0088FF".color, "0092FF".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["FF8FB3".color, "C86DD7".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["20C9BD".color, "2054C9".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["F5317F".color, "FF7C6E".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["9DB2C7".color, "647B95".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["06D5FA".color, "18C5FB".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["464FF5".color, "E760C4".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["89BF1C".color, "FDC100".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
        backgrounds.append(Background(colors: ["FFD600".color, "FF0100".color], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1)))
    }
    func selectedBackground() -> Background? {
        return backgrounds.object(at: selectedIndex)
    }
    
}

// MARK: - Utility Methods
extension ColorsBgAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension ColorsBgAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorBgCell.identifier, for: indexPath) as! ColorBgCell
        cell.viewColor.colors = backgrounds[indexPath.row].colors
        cell.viewColor.startPoint = backgrounds[indexPath.row].startPoint
        cell.viewColor.endPoint = backgrounds[indexPath.row].endPoint
        cell.viewBgColor.borderColor = indexPath.row == selectedIndex ? selectedBorderColor : .clear
        cell.viewBgColor.borderWidth = selectedBorderWidth
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
        
        didSelect(backgrounds[indexPath.row])
    }
}
