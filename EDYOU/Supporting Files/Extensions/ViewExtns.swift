//
//  ViewExtns.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import SDWebImage
import SkeletonView
import SwiftUI
import AVFoundation

extension UIView {
    
    func addShadow(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    func setShadow() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }
    
    func addBorders(withEdges edges: [UIRectEdge],
                    withColor color: UIColor,
                    withThickness thickness: CGFloat,
                    cornerRadius: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = thickness
        layer.cornerRadius = cornerRadius
        edges.forEach({ edge in
            
            switch edge {
            case .left:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                
            case .right:
                layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
            case .top:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
            case .bottom:
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
            default:
                break
            }
        })
    }
    
    
    func layoutIfNeeded(_ animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }, completion: { (_) in
                completion?()
            })
        } else {
            self.layoutIfNeeded()
            completion?()
        }
    }
    
    func addDashedCircle(dotedColor : UIColor = UIColor.white) {
        self.layer.cornerRadius = self.frame.width / 2
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor = dotedColor.cgColor//border of circle
        circleLayer.fillColor = UIColor.clear.cgColor//inside the circle
        circleLayer.lineJoin = .round
        circleLayer.lineDashPattern = [6,3]
        layer.addSublayer(circleLayer)
    }
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-8.0, 8.0, -8.0, 8.0, -4.0, 4.0, -2.0, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    var width: CGFloat {
        return frame.width
    }
    var height: CGFloat {
        return frame.height
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius =  newValue
            layer.masksToBounds = newValue > 0
            
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    func round() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width / 2.0
    }
    
    func addDashedBorder(color: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, lineDashPattern: [NSNumber] = [9,5]) {
        //        let color = borderColor ?? .green
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = lineDashPattern
        
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    
    func hideView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
            self.alpha = 1
        }
    }
    func showView() {
        if self.isHidden {
            self.alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    func startSkelting() {
        SkeletonAppearance.default.multilineHeight = 8
        SkeletonAppearance.default.multilineCornerRadius = 4
        self.isSkeletonable = true
        self.showAnimatedGradientSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAnimatedGradientSkeleton()
        }
    }
    func stopSkelting() {
        self.hideSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideSkeleton()
        }
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    var top: CGFloat {
        return self.frame.origin.y
    }
    var bottom: CGFloat {
        return self.frame.origin.y + self.frame.height
    }
    var left: CGFloat {
        return self.frame.origin.x
    }
    var right: CGFloat {
        return self.frame.origin.x + self.frame.width
    }
    
}


extension UIScrollView {
    
    
    @IBInspectable var contentAdjustment: Bool {
        get {
            return self.contentInsetAdjustmentBehavior != .never
        }
        set {
            contentInsetAdjustmentBehavior = newValue == true ? .automatic : .never
        }
    }
    
}



extension UICollectionViewCell {
    static var identifier: String {
        return "k\(String(describing: self))"
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}


extension UITableViewCell {
    static var identifier: String {
        return "k\(String(describing: self))"
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIImage
{
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage
    {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UIImageView {
    func setImage(url: String?, placeholder: UIImage? = nil, completion: (() -> Void)? = nil) {
        if let u = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.sd_setImage(with: URL(string: u), placeholderImage: placeholder) { _, _, _, _ in
                completion?()
            }
        } else {
            self.image = placeholder
            completion?()
        }
    }
    func setImage(url: String?, placeholderColor: UIColor?, completion: (() -> Void)? = nil) {
        self.backgroundColor = placeholderColor
        if let u = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            self.sd_imageIndicator = SDWebImageActivityIndicator.white
            self.sd_imageIndicator?.startAnimatingIndicator()
            
            self.sd_setImage(with: URL(string: u), placeholderImage: nil) { image, _, _, _ in
                self.sd_imageIndicator?.stopAnimatingIndicator()
                let color = image?.averageColor
                self.backgroundColor = color
                completion?()
                
            }
        } else {
            self.image = nil
            completion?()
        }
    }
    
    func setImage(url: String?, placeholder: UIImage?) {
        guard let urlString = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) , let urlValue = URL(string: urlString) else {
            //Set PlaceHolder
            if placeholder != nil{
                self.sd_setImage(with: nil, placeholderImage: placeholder)
            }
            return
        }
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_imageIndicator?.startAnimatingIndicator()
        self.sd_setImage(with: urlValue, placeholderImage: placeholder) { image, err, type, url in
            self.sd_imageIndicator?.stopAnimatingIndicator()
        }
        
    }
    
    func setImage(url: String?, placeholder: UIImage?,intials:String? = nil) {
        var newPlaceHolder:UIImage? = nil
        if newPlaceHolder == nil , intials != nil , let placeholder = prepareInitialsAvatar(for: intials!) {
            newPlaceHolder = placeholder
        }
        
        if newPlaceHolder == nil {
            newPlaceHolder = placeholder
        }
        guard let urlString = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) , let urlValue = URL(string: urlString) else {
            //Set PlaceHolder
            if newPlaceHolder != nil{
                self.sd_setImage(with: nil, placeholderImage: newPlaceHolder)
            }
            return
        }
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_imageIndicator?.startAnimatingIndicator()
        self.sd_setImage(with: urlValue, placeholderImage: newPlaceHolder) { image, err, type, url in
            self.sd_imageIndicator?.stopAnimatingIndicator()
        }
    }
    
    public func imageAvailableFromURL(urlString: String) -> Bool {
        if let imageUrl = URL(string: urlString)
        {
            
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(imageUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                do {
                    return true
                }
                
                catch
                {
                    return false
                }
                
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    public func imageFromURL(urlString: String, name: String) {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        //   if self.image == nil{
        self.image = UIImage.init(named: "imagePlaceholder")
        //  }
        
        if let imageUrl = URL(string: name)
        {
            
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(imageUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                do {
                    let data = try Data(contentsOf: destinationUrl)
                    let image = UIImage(data: data)
                    self.image = image
                }
                
                catch
                {
                    
                }
                
            }
            else
            {
                //
                //            if #available(iOS 15.0, *) {
                //
                //                do {
                //                let (asyncBytes, urlResponse) = try await URLSession.shared.bytes(from: NSURL(string: urlString)! as URL)
                //                let length = (urlResponse.expectedContentLength)
                //                var data = Data()
                //                data.reserveCapacity(Int(length))
                //
                //                for try await byte in asyncBytes {
                //                    data.append(byte)
                //                    let progress = Double(data.count) / Double(length)
                //                    print(progress)
                //                }
                //                    self.image = UIImage(data: data)
                //                }
                //                catch {
                //                    self.image = UIImage.init(named: "imagePlaceholder")
                //                }
                //            } else {
                
                URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        print(error ?? "No Error")
                        return
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        let image = UIImage(data: data!)
                        //  activityIndicator.removeFromSuperview()
                        
                        
                        do {
                            try data!.write(to: destinationUrl,options: .atomic)
                        } catch let error {
                            print("error saving file with error", error)
                        }
                        
                        
                        self.image = image
                        // then lets create your document folder url
                        
                        
                        
                        
                        
                    })
                    
                }).resume()
                // Fallback on earlier versions
                //  }
                
                
                
                
            }
            
        }
        
    }
    
    public func videoFromURL(urlString: String, name: String) {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.image = UIImage.init(named: "imagePlaceholder")
        }
        
        if let videoUrl = URL(string: name)
        {
            
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(videoUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                do {
                    let data = try Data(contentsOf: destinationUrl)
                    
                    self.getThumbnailImageFromVideoUrl(url: destinationUrl) { image in
                        self.image = image
                    }
                    
                    // let image = UIImage(data: data)
                    // self.image = image
                }
                
                catch
                {
                    
                }
                
            }
            else
            {
                URLSession.shared.downloadTask(with: videoUrl) { (location, response, error) -> Void in
                    // use guard to unwrap your optional url
                    guard let location = location else { return }
                    // create a deatination url with the server response suggested file name
                    let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoUrl.lastPathComponent)
                    
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        
                        self.getThumbnailImageFromVideoUrl(url: destinationURL) { image in
                            self.image = image
                        }
                    } catch { print(error) }
                    
                }.resume()
            }
        }
        
    }
    
    
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let request = URLRequest(url: url)
            let cache = URLCache.shared
            if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
                DispatchQueue.main.async { //8
                    completion(image)
                }
            }
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            //            let thumnailTime = CMTimeMake(value: 2, timescale: 1)  //5
            avAssetImageGenerator.maximumSize = CGSize(width: 200,height: 200)
            let thumnailTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                if let data = thumbNailImage.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedResponse, for: request)
                }
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    func prepareInitialsAvatar(for text: String) -> UIImage? {
        let scale = UIScreen.main.scale;
        var size = self.bounds.size;
        
        if self.contentMode == .redraw || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .scaleToFill {
            size.width = (size.width * scale);
            size.height = (size.height * scale);
        }
        
        guard size.width > 0 && size.height > 0 else {
            return nil;
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext();
            return nil;
        }
        let path = CGPath(ellipseIn: self.bounds, transform: nil);
        ctx.addPath(path);
        
        let colors = [UIColor.systemGray.adjust(brightness: 0.52).cgColor, UIColor.systemGray.adjust(brightness: 0.48).cgColor];
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!;
        ctx.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: []);
        //                    ctx.setFillColor(UIColor.systemGray.cgColor);
        //                    ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height));
        
        let textAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white.withAlphaComponent(0.9), .font: UIFont.systemFont(ofSize: size.width * 0.4, weight: .medium)];
        let textSize = text.size(withAttributes: textAttr);
        
        text.draw(in: CGRect(x: size.width/2 - textSize.width/2, y: size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: textAttr);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}

extension UITextField {
    
    func expectedText(changeCharactersIn range: NSRange, replacementString string: String) -> String {
        
        
        var expectedText = NSString(string: self.text ?? "").replacingCharacters(in: range, with: string)
        if let text = self.text {
            let oldText = text
            let inputString = string as NSString
            if range.location > 0 && range.length == 1 && inputString.length == 0 {//Backspace pressed
                //                self.deleteBackward()
                
                if let updatedText = self.text as NSString? {
                    if updatedText.length != oldText.count - 1 {
                        expectedText = ""
                    }
                }
            }
        }
        return expectedText
    }
    
}
extension UITextView {
    
    func expectedText(changeCharactersIn range: NSRange, replacementText text: String) -> String {
        
        
        var expectedText = NSString(string: self.text ?? "").replacingCharacters(in: range, with: text)
        if let text = self.text {
            let oldText = text
            let inputString = text as NSString
            if range.location > 0 && range.length == 1 && inputString.length == 0 {//Backspace pressed
                self.deleteBackward()
                
                if let updatedText = self.text as NSString? {
                    if updatedText.length != oldText.count - 1 {
                        expectedText = ""
                    }
                }
            }
        }
        return expectedText
    }
    
}
extension UITableView {
    
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }
        
        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1
        
        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }
        
        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1
        
        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }
        
        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
    func scrollToBottom(isAnimated:Bool = true){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1, section: self.numberOfSections - 1)
            if indexPath.row >= 0 && indexPath.section >= 0 {
                if self.hasRowAtIndexPath(indexPath: indexPath) {
                    self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
                }
            }
            
        }
    }
    
    func scrollToTop(isAnimated:Bool = true) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func addEmptyView(_ message: String, _ detail : String?, _ image : UIImage?, _ center : CGPoint = .zero) {
        let backgroundV = UIView(frame: self.bounds)
//        backgroundV.backgroundColor = .yellow
        let height = self.bounds.height
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: height/2, width: self.bounds.width, height: 110))
//        stackView.backgroundColor = .gray
        let titleLbl = UILabel()
        titleLbl.text = message
        titleLbl.textColor = UIColor.black
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.sizeToFit()
        titleLbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        titleLbl.backgroundColor = .gray
        let detailLbl = UILabel()
        detailLbl.text = detail
        detailLbl.textColor = UIColor.black
        detailLbl.numberOfLines = 0
        detailLbl.textAlignment = .center
        detailLbl.sizeToFit()
        detailLbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        detailLbl.backgroundColor = .concrete
        let imgV = UIImageView()
//        imgV.backgroundColor = .clouds
        imgV.image = image
        imgV.contentMode = .scaleAspectFit
        
        
//        stackView.backgroundColor = .red
//        titleLbl.backgroundColor = .green
//        detailLbl.backgroundColor = .giphyGreen
        stackView.addArrangedSubview(imgV)
        stackView.addArrangedSubview(titleLbl)
        stackView.addArrangedSubview(detailLbl)
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        
//        stackView.center = center
        backgroundV.addSubview(stackView)
        self.backgroundView = backgroundV
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
}

extension UICollectionView{
    
    func addEmptyView(_ message: String, _ detail : String?, _ image : UIImage?, _ center : CGPoint = .zero) {
        let backgroundV = UIView(frame: self.bounds)
//        backgroundV.backgroundColor = .yellow
        let height = self.bounds.height
        let y =  (height/2) - 32
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: y, width: self.bounds.width, height: 96))
//        stackView.backgroundColor = .gray
        let titleLbl = UILabel()
        titleLbl.text = message
        titleLbl.textColor = UIColor.black
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.sizeToFit()
        
        let detailLbl = UILabel()
        detailLbl.text = detail
        detailLbl.textColor = UIColor.black
        detailLbl.numberOfLines = 0
        detailLbl.textAlignment = .center
        detailLbl.sizeToFit()
        
        let imgV = UIImageView()
        imgV.image = image
        imgV.contentMode = .scaleAspectFit
        
        
//        stackView.backgroundColor = .red
//        titleLbl.backgroundColor = .green
//        detailLbl.backgroundColor = .giphyGreen
        stackView.addArrangedSubview(titleLbl)
        stackView.addArrangedSubview(imgV)
        stackView.addArrangedSubview(detailLbl)
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.axis = .vertical
        
//        stackView.center = center
        backgroundV.addSubview(stackView)
        self.backgroundView = backgroundV
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}


func generateHapticFeedback() {
    if #available(iOS 10.0, *) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UUID {
    var getCleanString:String {
        return self.uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    }
}
