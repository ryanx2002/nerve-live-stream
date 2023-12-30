//
//  VerificationCodeManager.swift
//  NerveLive
//
//  Created by wbx on 2023/12/5.
// UNUSED

import UIKit
import Amplify
import AmplifyPlugins

/// 短信验证码功能管理类
class VerificationCodeManager: NSObject {
    static let shared = VerificationCodeManager()
    private override init() {}

    /// 获取验证码
    /// - Parameter mobile: +手机号
    func getVerificationCode(for mobile: String) {
        Amplify.Auth.resetPassword(for: mobile) { result in
            switch result {
            case .success(let resetResult):
                // 短信验证码已发送成功
                debugPrint("Password reset sent: \(resetResult)")
            case .failure(let error):
                // 发送短信验证码时发生错误
                debugPrint("Error sending password reset: \(error)")
            }
        }
    }

    /// 校验验证码
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - code: 验证码
    func confirmVerificationCode(for mobile: String, code: String) {
        // 验证短信验证码
        Amplify.Auth.confirmResetPassword(for: mobile, with: code, confirmationCode: code) { result in
            switch result {
            case .success:
                // 短信验证码验证成功
                print("Password reset confirmed")
            case .failure(let error):
                // 验证短信验证码时发生错误
                print("Error confirming password reset: \(error)")
            }
        }
    }
}
