//
//  PhoneInputViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit
import Amplify
import SVProgressHUD
import SwiftUI

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
        self.PhoneNumberInputText.returnKeyType = .done
        self.PhoneNumberInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "(123)456-7890")
        self.PhoneNumberInputText.delegate = self
        self.PhoneNumberInputText.becomeFirstResponder()
        self.PhoneNumberInputText.keyboardType = .numbersAndPunctuation
        self.PhoneNumberInputText.textContentType = .telephoneNumber
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 9
        let currentString = (textField.text ?? "") as NSString
        var newString = currentString.replacingCharacters(in: range, with: string)
        let lenNew = newString.count
        
        if newString.filter{ $0.isNumber }.count == lenNew - 1 {
            return false
        }
        
        let res = lenNew <= maxLength
        if !res {
            if lenNew == 10 {
                debugPrint(newString)
                textField.text = newString
                submitText(countryCode: self.CountryCodeInputText.text ?? "+1", number: textField.text!)
                return false
            } else if newString.starts(with: "+1"){
                newString = newString.filter{ $0.isNumber }
                newString.remove(at: newString.startIndex)
                if newString.count == 10 {
                    textField.text = newString
                    submitText(countryCode: self.CountryCodeInputText.text ?? "+1", number: textField.text!)
                }
                return false
            } else {
                textField.text = String(currentString)
            }
        }
        return res
    }
    
    func submitText(countryCode: String?, number : String) {
        RegisterCache.sharedTools.countryCode = countryCode ?? "+1"
        RegisterCache.sharedTools.phone = number
        let loginPage = number == "8159912449" || number == "9462108010"
        let fullNumber = RegisterCache.sharedTools.countryCode + number
        if loginPage {
            let vc = AuditLoginViewController()
            vc.isMaster = self.PhoneNumberInputText.text == "8159912449"
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            LoginBackend.shared.queryUserBy(phone: fullNumber) { user in
                if user != nil {
                    UserManager.saveUerInfo(model: user!)
                    debugPrint("saving found user")
                    DispatchQueue.main.async{
                        self.resendCodeForSignIn()
                    }
                } else {
                    self.signUp()
                }
            } fail: { msg in
                self.signUp()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!StringUtils.isBlank(value: self.CountryCodeInputText.text) &&
           !StringUtils.isBlank(value: self.PhoneNumberInputText.text) && self.PhoneNumberInputText.text!.count == 10 && self.PhoneNumberInputText.text!.filter{$0.isNumber}.count == 10) {
            /// 审核账号
            if self.PhoneNumberInputText.text == "8159912449" ||
                self.PhoneNumberInputText.text == "9462108010" {
                let vc = AuditLoginViewController()
                vc.isMaster = self.PhoneNumberInputText.text == "8159912449"
                navigationController?.pushViewController(vc, animated: true)
            } else {
                RegisterCache.sharedTools.countryCode = CountryCodeInputText.text ?? "+1"
                RegisterCache.sharedTools.phone = (PhoneNumberInputText.text ?? "").filter{ $0.isNumber }
                // "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)"
                //"7048901338"
                /// 根据手机号查询用户
                LoginBackend.shared.queryUserBy(phone: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)") { user in
                    if let _ = user {
                        let vc = AuditLoginViewController()
                        vc.isMaster = self.PhoneNumberInputText.text == "8159912449"
                        self.navigationController?.pushViewController(vc, animated: true)
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
            } else {
                SVProgressHUD.showError(withStatus: "Please enter a valid phone number")
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
    func resendCodeForSignIn() {
        Amplify.Auth.resetPassword(for: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)") { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                DispatchQueue.main.async {
                    let vc = ConfirmationCodeViewController()
                    vc.isLogin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    func resendCodeForSignUp() {
        LoginBackend.shared.resendCodeForSignUp(username: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)") {
            print("send code success")
            DispatchQueue.main.async {
                let vc = ConfirmationCodeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } fail: { msg in
            //msg: AuthError: User is already confirmed.\nRecovery suggestion: Make sure that the parameters passed are valid\nCaused by:\ninvalidParameter
            debugPrint("msg====>\(msg)")
            DispatchQueue.main.async {
                self.showFail()
            }
        }
    }
    
    func showFail() {
        let alert = UIAlertController(title: "Tips", message: "Failed to send the verification code.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            let vc = ConfirmationCodeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Resend", style: .default, handler: { _ in
            alert.dismiss(animated: true)
            self.resendCodeForSignUp()
        }))
        present(alert, animated: true)
    }
}

// preview stuff. note Amplify functions cause preview to crash

struct PhoneInputView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PhoneInputViewController
    func makeUIViewController(context: Context) -> PhoneInputViewController {
            let vc = PhoneInputViewController()
            return vc
        }
    func updateUIViewController(_ uiViewController: PhoneInputViewController, context: Context) {
        }
    }

struct PhoneInputPreview: PreviewProvider {
    static var previews: some View {
        return PhoneInputView()
    }
}
