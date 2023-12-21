//
//  PhoneInputViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit
import Amplify
import SVProgressHUD

class PhoneInputViewController: BaseViewController {
    @IBOutlet weak var DescTitle:UILabel!
    @IBOutlet weak var CountryCodeInputText:UITextField!
    @IBOutlet weak var PhoneNumberInputText:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DescTitle.attributedText = StringUtils.TextWithBorder(font: 20, text: "What’s your phone number?")
        self.CountryCodeInputText.textAlignment = .right
        self.CountryCodeInputText.font = UIFont.font(ofSize: 32, type: .Bold)
        let attributedString = NSMutableAttributedString(string: "+1")
        // 添加下划线
        let underlineStyle = NSUnderlineStyle.single.rawValue
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineStyle, range: NSRange(location: 0, length: attributedString.length))
        self.CountryCodeInputText.attributedText = attributedString
        self.CountryCodeInputText.isEnabled = false
        self.CountryCodeInputText.delegate = self;
        self.CountryCodeInputText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.PhoneNumberInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "(610)555-0123")
        self.PhoneNumberInputText.delegate = self
        self.PhoneNumberInputText.returnKeyType = .done
//        Amplify.Auth.signOut { _ in
//            print("退出登录成功")
//
//            /// +19452007009  +17048901338
//            LoginBackend.shared.login(userName: "+19452007009", pwd: RegisterCache.sharedTools.password) {
//
//            } fail: { msg in
//
//            } confirmSignUp: {
//
//            }
//        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let attributedString = NSMutableAttributedString(string: textField.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        self.CountryCodeInputText.attributedText = attributedString
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIViewSetFrameWidth(view: self.CountryCodeInputText, width: 40)
        UIViewSetFrameWidth(view: self.PhoneNumberInputText, width: 220)
        let orginX = (K_SCREEN_WIDTH - 40 - 220 - 10) / 2.0
        UIViewSetFrameX(view: self.CountryCodeInputText, x: orginX)
        UIViewSetFrameX(view: self.PhoneNumberInputText, x: self.CountryCodeInputText.frame.maxX + 10)
    }
}

extension PhoneInputViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!StringUtils.isBlank(value: self.CountryCodeInputText.text) &&
           !StringUtils.isBlank(value: self.PhoneNumberInputText.text)) {
            /// 审核账号
            if self.PhoneNumberInputText.text == "8159912449" ||
                self.PhoneNumberInputText.text == "9462108010" {
                let vc = AuditLoginViewController()
                vc.isMaster = self.PhoneNumberInputText.text == "8159912449"
                navigationController?.pushViewController(vc, animated: true)
            } else {
                RegisterCache.sharedTools.countryCode = CountryCodeInputText.text ?? "+1"
                RegisterCache.sharedTools.phone = PhoneNumberInputText.text ?? ""
                // "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)"
                //"7048901338"
                /// 根据手机号查询用户
                LoginBackend.shared.queryUserBy(phone: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)") { user in
                    if let _ = user {
                        self.resendCode()
                    } else {
                        self.signUp()
                    }
                } fail: { msg in
                    self.signUp()
                }
            }
        } else {
            if (self.CountryCodeInputText.text ?? "").count <= 0 {
                SVProgressHUD.showError(withStatus: "Please enter the area code")
                return false
            }
            if (self.PhoneNumberInputText.text ?? "").count <= 0 {
                SVProgressHUD.showError(withStatus: "Please enter the phone number")
                return false
            }
        }
        textField.resignFirstResponder()
        return true
    }

    /// 注册
    func signUp() {
        LoginBackend.shared.signUp(for: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)", password: RegisterCache.sharedTools.password) {
            DispatchQueue.main.async {
                let vc = ConfirmationCodeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } suc: {
            print("send code success")
        } fail: { error in
            print("signUp fail \(error)")
            DispatchQueue.main.async {
                self.showFail()
            }
        }
    }
    
    /// 重发验证码
    func resendCode() {
        LoginBackend.shared.resendCodeForSignUp(username: RegisterCache.sharedTools.phone) {
            print("send code success")
            DispatchQueue.main.async {
                let vc = ConfirmationCodeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } fail: { msg in
            DispatchQueue.main.async {
                self.showFail()
            }
        }
    }
    
    func showFail() {
        let alert = UIAlertController(title: "Tips", message: "Failed to send the verification code.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Resend", style: .default, handler: { _ in
            alert.dismiss(animated: true)
            self.resendCode()
        }))
        present(alert, animated: true)
    }
}
