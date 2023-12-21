//
//  UIColorExtension.swift
//  Boyaios
//
//  Created by Jan on 2020/12/29.
//  Copyright © 2020 yind. All rights reserved.
//

import Foundation
import UIKit
 
//UIColor扩展
extension UIColor {
     
    //使用rgb方式生成自定义颜色
    convenience init(_ r : CGFloat, _ g : CGFloat, _ b : CGFloat)
    {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
     
    //使用rgba方式生成自定义颜色
    convenience init(_ r : CGFloat, _ g : CGFloat, _ b : CGFloat, _ a : CGFloat)
    {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: a)
    }
    //16进制生成自定义颜色
    class func hexColorWithAlpha(color: String, alpha:CGFloat) -> UIColor
    {
        var colorString = color.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        if colorString.hasPrefix("0x") {
            colorString = (colorString as NSString).substring(from: 2)
        }
        if colorString.hasPrefix("#") {
            colorString = (colorString as NSString).substring(from: 1)
        }
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        var rang = NSRange()
        rang.location = 0
        rang.length = 2
        
        let rString = (colorString as NSString).substring(with: rang)
        rang.location = 2
        let gString = (colorString as NSString).substring(with: rang)
        rang.location = 4
        let bString = (colorString as NSString).substring(with: rang)
        
        var r:UInt64 = 0, g:UInt64 = 0,b: UInt64 = 0
        
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        return UIColor.init(CGFloat(r), CGFloat(g), CGFloat(b), alpha)
    }
}
