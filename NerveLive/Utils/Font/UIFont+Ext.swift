//
//  UIFont+Ext.swift
//  Nerve
//
//  Created by wbx on 2023/10/11.
//

import Foundation
import UIKit

enum FontType: String {
    case Regular    = "Regular"
    case SemiBold   = "SemiBold"
    case Bold       = "Bold"
}

extension UIFont {
    class func font(ofSize fontSize: CGFloat, type: FontType) -> UIFont {
        let fontName = "inter-\(type.rawValue)"
        if let font = UIFont.init(name: fontName, size: fontSize) {
            return font
        }
        return .systemFont(ofSize: fontSize)
    }
}
