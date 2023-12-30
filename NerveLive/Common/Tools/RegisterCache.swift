//
//  RegisterCache.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/22.
//

import UIKit

class RegisterCache: NSObject {
    static let sharedTools = RegisterCache()
    private override init() {

    }
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = "NerveLive123456"
    var countryCode = "" // 国家号
    var phone = "" // 手机号
    var verificationCode = "" // 验证码
}
