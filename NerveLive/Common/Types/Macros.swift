//
//  Global.swift
//  Boyaios
//
//  Created by huasen on 2020/2/27.
//  Copyright © 2020 yind. All rights reserved.
//

import Foundation
import UIKit

let kScreenBounds = UIScreen.main.bounds
//屏高
let kScreenHeight = kScreenBounds.size.height
//屏宽
let kScreenWidth = kScreenBounds.size.width
//屏幕大小
let kScreenSize = kScreenBounds.size

let keyWindow:UIWindow? = UIApplication.shared.delegate?.window ?? nil

/// 通过 十六进制与alpha来设置颜色值  （ 样式： 0xff00ff ）
public let HexRGBAlpha:((Int,Float) -> UIColor) = { (rgbValue : Int, alpha : Float) -> UIColor in
    return UIColor(red: CGFloat(CGFloat((rgbValue & 0xFF0000) >> 16)/255), green: CGFloat(CGFloat((rgbValue & 0xFF00) >> 8)/255), blue: CGFloat(CGFloat(rgbValue & 0xFF)/255), alpha: CGFloat(alpha))
}

let kAppdelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

let bottomSafeAreaHeight = keyWindow?.safeAreaInsets.bottom ?? 0.0
