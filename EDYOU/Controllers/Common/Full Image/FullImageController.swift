//
//  FullImageController.swift
//  EDYOU
//
//  Created by  Mac on 24/10/2021.
//

import UIKit
import ImageSlideshow

class FullImageController: UIViewController {

    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    var images = [SDWebImageSource]()
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showImages()
    }
    
    init(images: [String], selectedIndex: Int) {
        super.init(nibName: FullImageController.name, bundle: nil)
        
        var source = [SDWebImageSource]()
        
        for i in images {
            if let u = URL(string: i) {
                source.append(SDWebImageSource(url: u))
            }
        }
        self.images = source
        self.selectedIndex = selectedIndex
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    func showImages() {
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit

        slideshow.pageIndicator = UIPageControl.withSlideshowColors()
        

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(images)
        slideshow.setCurrentPage(selectedIndex, animated: false)

//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap))
//        slideshow.addGestureRecognizer(recognizer)
    }
    
}

extension FullImageController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
//        print("current page:", page)
    }
}
