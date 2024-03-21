//
//  OnboardingController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

class OnboardingController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var viewPageIndicator: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgPhone: UIImageView!

    // MARK: - Properties
    private var currentPage: Int = 0
    private var colors = [R.color.onboarding_0(), R.color.onboarding_1(), R.color.onboarding_2(), R.color.onboarding_3()]
    private var images = [R.image.onboarding_0(), R.image.onboarding_1(), R.image.onboarding_2(), R.image.onboarding_3()]
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrentPageUI()
    }
    
    

}


// MARK: - Actions
extension OnboardingController {
    @IBAction func didTapLetsGoButton(_ sender: UIButton) {
        let controller = WelcomeController()
        navigationController?.pushViewController(controller, animated: true)
    }
}


// MARK: - Utility Methods
extension OnboardingController {
    func updateCurrentPageUI() {
        view.backgroundColor = colors[currentPage]
        imgPhone.image = images[currentPage]
        
        stackView.removeArrangedSubview(viewPageIndicator)
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        
        stackView.insertArrangedSubview(viewPageIndicator, at: Int(currentPage))
        stackView.setNeedsLayout()
    }
    
}


// MARK: - ScrollView Delegate
extension OnboardingController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        if page != currentPage {
            
            currentPage = page
            if currentPage >= 0 && currentPage < 4 {
                updateCurrentPageUI()
            }
            
        }
        
        
    }
}
