//
//  LiveManager+SignIn.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import Foundation
import AWSMobileClient

/// 登录/注销操作
extension LiveManager {
    /// 直播用户登录
    /// 功能等同于 AWSMobileClient.default().initialize
    func singIn() {
        AWSMobileClient.default().signIn(username: LoginTools.sharedTools.userId(), password: RegisterCache.sharedTools.password) { (signInResult, error) in

            DispatchQueue.main.async {
                if let error = error {
                    print("AWSMobileClient signIn error=======>\(error)")
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                    case .signedIn:
                        print("AWSMobileClient signedIn")
                    default:
                        break
                    }
                }
            }
        }
    }
    
    /// 注销当前登录的用户并清除本地密钥链存储。
    /// 注意:这不会使服务中的令牌无效，也不会使用户退出其他设备。
    func signOut() {
        AWSMobileClient.default().signOut()
    }
}
