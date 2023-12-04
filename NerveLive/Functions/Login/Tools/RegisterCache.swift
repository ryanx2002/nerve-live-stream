//
//  RegisterCache.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/22.
//

import UIKit

class RegisterCache: NSObject {
    static let sharedTools = RegisterCache()
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = ""
}
