//
//  ArrowViewConfiguration.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/30.
//

import UIKit

// MARK: 相册标题视图配置类，弹窗展示相册列表时有效
public struct ArrowViewConfiguration {
    
    /// 箭头背景颜色
    public var backgroundColor: UIColor = .black
    
    /// 箭头颜色
    public var arrowColor: UIColor = "#ffffff".hx_Color
    
    /// 暗黑风格下箭头背景颜色
    public var backgroudDarkColor: UIColor = "#ffffff".hx_Color
    
    /// 暗黑风格下箭头颜色
    public var arrowDarkColor: UIColor = "#333333".hx_Color
    
    public init() { }
}
