//
//  StringExtension.swift
//  Boyaios
//
//  Created by huasen on 2020/2/28.
//  Copyright © 2020 yind. All rights reserved.
//

import Foundation
import UIKit

class StringUtils:NSObject{
    static func isBlank(value: String?) -> Bool {
        //首先判断是否为nil
        if (nil == value) {
            //对象是nil，直接认为是空串
            return true
        }else{
            //然后是否可以转化为String
            if let myValue = value {
                //然后对String做判断
                return myValue == "" || myValue == "(null)" || 0 == myValue.count
            }else{
                //字符串都不是，直接认为是空串
                return true
            }
        }
    }
    
    static func TextWithBorder(font:CGFloat,text:String) -> NSMutableAttributedString{
        // 创建白色字体属性
        let whiteColor = UIColor.white
        let whiteFontAttribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: whiteColor,
            NSAttributedString.Key.font: UIFont.font(ofSize: font, type: .Regular)

        ]

        // 创建红色描边属性
        let redColor = UIColor.red
        let redStrokeAttribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5).cgColor,
            NSAttributedString.Key.strokeWidth: -4.0, // 负值表示描边
            NSAttributedString.Key.foregroundColor: whiteColor, // 设置字体颜色，可以和白色保持一致
            NSAttributedString.Key.font: UIFont.font(ofSize: font, type: .Regular)
        ]

        // 创建富文本字符串
        let attributedText = NSMutableAttributedString(string: text, attributes: whiteFontAttribute)

        // 应用描边属性
        attributedText.addAttributes(redStrokeAttribute, range: NSRange(location: 0, length: text.count))
        return attributedText
    }
    
    static func PlaceholderAttributeText(contentText:String) -> NSAttributedString{
        let countryAttributeText = NSAttributedString(string: contentText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexColorWithAlpha(color: "#A9A9A9", alpha: 1)])
        return countryAttributeText
    }
    
    static func AddUnderlineForText(attributedString:NSMutableAttributedString,startRange:Int,rangeLen:Int) -> NSMutableAttributedString{
        // add under line
        let underlineStyle = NSUnderlineStyle.single.rawValue
attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineStyle, range: NSRange(location: startRange, length: rangeLen))
        return attributedString
    }
    
    static func SplitTextWithFontAndReturnLine(contentText:String,prefont:CGFloat,afterfont:CGFloat,splitString:String) -> NSAttributedString{
        let attributedText = NSMutableAttributedString(string: contentText)

        // 查找分号的位置
        if let range = contentText.range(of: splitString) {
            let startIndex = contentText.distance(from: contentText.startIndex, to: range.lowerBound)
            
            // 前半部分（使用16号字体）
            attributedText.addAttribute(.font, value: UIFont.font(ofSize: prefont, type: .Bold), range: NSRange(location: 0, length: startIndex))
            
            // 分号之后的部分（使用12号字体，并添加换行符）
            let endIndex = contentText.count - startIndex
            attributedText.addAttribute(.font, value: UIFont.font(ofSize: afterfont, type: .Regular), range: NSRange(location: startIndex, length: endIndex))
            attributedText.replaceCharacters(in: NSRange(location: startIndex, length: 1), with: "\n")
        }
        return attributedText
    }
}
