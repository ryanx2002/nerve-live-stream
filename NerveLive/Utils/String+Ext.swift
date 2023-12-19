//
//  String+Ext.swift
//  Nerve
//
//  Created by wbx on 2023/10/17.
//

import Foundation

extension String {
    //获取字符串首字母并大写

    func getFirstAlphabet() -> String {
        if self.count <= 0 { return "" }
        let str1:CFMutableString = CFStringCreateMutableCopy(nil, 0, self as CFString);
          CFStringTransform(str1, nil, kCFStringTransformToLatin, false)
          CFStringTransform(str1, nil, kCFStringTransformStripCombiningMarks, false)
          let str2 = CFStringCreateWithSubstring(nil, str1, CFRangeMake(0, 1))
        return str2! as String
    }

//    func getAcronym(separator: String = "") -> String {
//        let acronym = self.components(separatedBy: CharacterSet.whitespacesAndNewlines).map({
//            String($0.first) }).joined(separator: separator)
//        return acronym
//    }

    // Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    // NSRange转换为Range
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
                                     limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
