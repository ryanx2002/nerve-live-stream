//
//  UIColor+Ext.swift
//  UXin
//
//  Created by wbx on 2019/12/19.
//  Copyright © 2019 Vcom. All rights reserved.
//

import Foundation
import UIKit

let FLOAT_1_255: CGFloat = 1.0 / 255

func RGB2FLOAT(val: CGFloat) -> CGFloat {
    return ((val) * FLOAT_1_255)
}

func RGB_RED(val: CGFloat) -> CGFloat {
    return (CGFloat(((Int(val)) & 0xff0000) >> 16))
}

func RGB_GREEN(val: CGFloat) -> CGFloat {
    return (CGFloat(((Int(val)) & 0xff00) >> 8))
}

func RGB_BLUE(val: CGFloat) -> CGFloat {
    return (CGFloat(((Int(val)) & 0xff)))
}

func RGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return UIColor(red: (r) / 255.0, green: (g) / 255.0, blue: (b) / 255.0, alpha: 1)
}

func RGB3(_ a: CGFloat) -> UIColor {
    return UIColor(red: (a) / 255.0, green: (a) / 255.0, blue: (a) / 255.0, alpha: 1)
}

func RGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: (r) / 255.0, green: (g) / 255.0, blue: (b) / 255.0, alpha: a)
}
