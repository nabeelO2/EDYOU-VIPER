//
//  ReusableFiltersViewModel.swift
//  EDYOU
//
//  Created by admin on 27/08/2022.
//

import Foundation
import UIKit
class ReusableFiltersViewModel {
    var resultedFilter = [FilterOptions]()
    let peopleFilters =
    
    [FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere",filterType: .dropdown,defaultValue: "Anywhere"),
     FilterOptions(image: UIImage(named: "University-Green"), title: "University", isSwitch: false, value: "Any University",filterType: .dropdown,defaultValue: "Any University"),
     FilterOptions(image: UIImage(named: "Work-Green"), title: "Work", isSwitch: false, value: "Any Company",filterType: .textField,defaultValue: "Any Company"),
     FilterOptions(image: UIImage(named: "Friends-green"), title: "Friends of Friends", isSwitch: true, value: "",filterType: .boolean)]
    
    let friendsFilters =
    [FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere", filterType: .dropdown,defaultValue: "Anywhere"),
     FilterOptions(image: UIImage(named: "University-Green"), title: "University", isSwitch: false, value: "Any University", filterType: .dropdown,defaultValue: "Any University"),
     FilterOptions(image: UIImage(named: "Work-Green"), title: "Work", isSwitch: false, value: "Any Company", filterType: .textField,defaultValue: "Any Company"),
     FilterOptions(image: UIImage(named: "Friends-green"), title: "Friends of Friends", isSwitch: true, value: "", filterType: .boolean)]
    
    let groupsFilters =
    [FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere", filterType: .dropdown,defaultValue: "Anywhere"),
     FilterOptions(image: UIImage(named: "Public-Groups"), title: "Public Groups", isSwitch: true, value: "", filterType: .boolean),
     FilterOptions(image: UIImage(named: "My-groups"), title: "My Groups", isSwitch: true, value: "", filterType: .boolean)]
    
    let eventsFilters =
    [FilterOptions(image: UIImage(named: "Online"), title: "Online Events", isSwitch: true, value: "", filterType: .boolean),
     FilterOptions(image: UIImage(named: "PaidEvents"), title: "Paid Events", isSwitch: true, value: "", filterType: .boolean),
     FilterOptions(image: UIImage(named: "Classes"), title: "Classes", isSwitch: true, value: "", filterType: .boolean),
     FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere", filterType: .dropdown,defaultValue: "Anywhere"),
     FilterOptions(image: UIImage(named: "Dates"), title: "Dates", isSwitch: false, value: "Any Date", filterType: .datePicker,defaultValue: "Any Date"),
     FilterOptions(image: UIImage(named: "Categories"), title: "Categories", isSwitch: false, value: "Any Category", filterType: .dropdown,defaultValue: "Any Category"),
     FilterOptions(image: UIImage(named: "Friends-green"), title: "Popular with Friends", isSwitch: true, value: "", filterType: .boolean)]
    
    let postsFilters =
    [FilterOptions(image: UIImage(named: "Recent-Posts"), title: "Recent Posts", isSwitch: true, value: "",filterType: .boolean),
     FilterOptions(image: UIImage(named: "University-Green"), title: "University", isSwitch: false, value: "Any University", filterType: .dropdown,defaultValue: "Any University"),
     FilterOptions(image: UIImage(named: "Dates"), title: "Date Posted", isSwitch: false, value: "Any Date", filterType: .datePicker,defaultValue: "Any Date"),
     FilterOptions(image: UIImage(named: "Public-Groups"), title: "Posts From", isSwitch: false, value: "Anyone", filterType: .dropdown,defaultValue: "Anyone"),
     FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere", filterType: .dropdown,defaultValue: "Anywhere")]
    let friendRequestsFilters =
    [FilterOptions(image: UIImage(named: "icon-leave"), title: "Recived Request", isSwitch: false, value: "",filterType: .none),
     FilterOptions(image: UIImage(named: "replyIcon"), title: "Sent Request", isSwitch: false, value: "", filterType: .none,defaultValue: "")]
    let friendsSortFilters =
    [FilterOptions(image: UIImage(named: "icon-map-pin"), title: "City", isSwitch: false, value: "Anywhere", filterType: .dropdown,defaultValue: "Anywhere"),
     FilterOptions(image: UIImage(named: "University-Green"), title: "University", isSwitch: false, value: "Any University", filterType: .dropdown,defaultValue: "Any University"),
     FilterOptions(image: UIImage(named: "Work-Green"), title: "Work", isSwitch: false, value: "Any Company", filterType: .textField,defaultValue: "Any Company")]
    func getResultedOptions(layout: SearchType) ->  [FilterOptions]{
        switch layout {
        case .people:
            self.resultedFilter = peopleFilters
        case .friends:
            self.resultedFilter = friendsFilters
        case .groups:
            self.resultedFilter = groupsFilters
        case .events:
            self.resultedFilter = eventsFilters
        case .posts:
            self.resultedFilter = postsFilters
        case .friendRequests:
            self.resultedFilter = friendRequestsFilters
        case .friendsSort:
            self.resultedFilter = friendsSortFilters
//        case .trending:
//            break
        }
        return resultedFilter
    }
  
}
