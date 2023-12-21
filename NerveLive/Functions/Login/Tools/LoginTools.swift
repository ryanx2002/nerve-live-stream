//
//  LoginTools.swift
//  NerveLive
//
//  Created by wbx on 2023/12/5.
//

import UIKit

class LoginTools: NSObject {
    static let sharedTools = LoginTools()

    func saveUserInfo(dic: [String: Any] ) {
        if let user = User.deserialize(from: dic) {
            UserManager.saveUerInfo(model: user)
        }
    }

    func removeUserInfo(){
        UserManager.clearUserInfo()
    }

    func userId() -> String {
        let model: User = UserManager.readUserInfo()
        return model.id
    }

    func userName() -> String {
        let firstName = userInfo().firstName ?? ""
        let lastName = userInfo().lastName ?? ""
        return "\(lastName) \(firstName)"
    }

    func userInfo() -> User {
        let model: User = UserManager.readUserInfo()
        return model
    }

    private override init() {

    }
}
