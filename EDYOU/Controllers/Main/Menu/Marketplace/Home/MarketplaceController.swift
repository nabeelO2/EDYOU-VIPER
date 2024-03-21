//
//  MarketplaceController.swift
//  EDYOU
//
//  Created by  Mac on 22/10/2021.
//

import UIKit

class MarketplaceController: BaseController {
    
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var lblNumberOfItems: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    var adapter: MarketplaceAdapter!
    var categories: [MarketplaceCategory] = [.fashion, .sport, .entertainment, .electronics, .education, .vehicles]
    
    var selectedCategory = MarketplaceCategory.fashion
    var selectedLocation: LocationModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = MarketplaceAdapter(collectionView: collectionView)
        
        lblCategory.text = categories.first?.name
        LocationManager.shared.getCurrentLocation { [weak self] clLocation in
            LocationManager.shared.reverseGeocodeCoordinate(clLocation.coordinate) { [weak self] location, error in
                self?.selectedLocation = location
                self?.lblLocation.text = location?.formattAdaddress
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAds(query: txtSearch.text?.trimmed ?? "")
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstCollectionViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstCollectionViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }

}


// MARK: Actions
extension MarketplaceController {
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        viewSearch.showView()
    }
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        txtSearch.text = ""
        viewSearch.hideView()
        getAds(query: "")
    }
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
        getAds(query: "")
    }
    @IBAction func didTapLocationButton(_ sender: UIButton) {
        let controller = SelectLocationController(title: "Select Location", selectedLocation: selectedLocation) { location in
            self.selectedLocation = location
            self.lblLocation.text = location.formattAdaddress
        }
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func didTapCategoryButton(_ sender: UIButton) {
        var cats = [DataPickerItem<String>]()
        for c in categories {
            let cat = DataPickerItem<String>(title: c.name, data: c.rawValue)
            if c == selectedCategory {
                cat.isSelected = true
            }
            cats.append(cat)
        }
        
        let controller = DataPickerController(title: "Category", data: cats, singleSelection: true) { selectedItems in
            if let cat = selectedItems.first {
                self.selectedCategory = MarketplaceCategory(rawValue: cat.data ?? "") ?? .fashion
                self.lblCategory.text = cat.title.replacingOccurrences(of: "  ", with: " ")
                self.getAds(query: self.txtSearch.text ?? "")
            }
            
        }
        self.present(controller, animated: true, completion: nil)
    }
}



// MARK: TextField Delegate
extension MarketplaceController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        btnClear.isHidden = expectedText.count == 0
        print(expectedText)
        getAds(query: expectedText)
        return true
        
    }
}

// MARK: TextField Delegate
extension MarketplaceController {
    func getAds(query: String) {
        APIManager.social.getAds(query: query, category: selectedCategory) { ads, error in
            self.adapter.isLoading = false
            if error == nil {
                self.adapter.ads = ads
            } else {
                self.showErrorWith(message: error!.message)
            }
            let i = ads.count == 1 ? "item" : "items"
            self.lblNumberOfItems.text = "\(ads.count) \(i) found"
            self.lblNumberOfItems.isHidden = false
            self.collectionView.reloadData()
            
        }
    }
}

