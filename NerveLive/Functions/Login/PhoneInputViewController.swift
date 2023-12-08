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
        self.CountryCodeInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "+1")
        self.CountryCodeInputText.delegate = self;
        self.PhoneNumberInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "(610)555-0123")
        self.PhoneNumberInputText.delegate = self

        Amplify.Auth.signOut { _ in
            print("退出登录成功")

            LoginBackend.shared.login(userName: "+17048901338", pwd: RegisterCache.sharedTools.password) {

            } fail: { msg in

            } confirmSignUp: {

            }
        }
    }
}

extension PhoneInputViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!StringUtils.isBlank(value: self.CountryCodeInputText.text) &&
           !StringUtils.isBlank(value: self.PhoneNumberInputText.text)) {
            RegisterCache.sharedTools.countryCode = CountryCodeInputText.text ?? ""
            RegisterCache.sharedTools.phone = "+17048901338"//PhoneNumberInputText.text ?? ""
            LoginBackend.shared.signUp(for: RegisterCache.sharedTools.phone, password: RegisterCache.sharedTools.password) {
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
        textField.resignFirstResponder()
        return true
    }

    func showFail() {
        let alert = UIAlertController(title: "Tips", message: "Failed to send the verification code.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Resend", style: .default, handler: { _ in
            alert.dismiss(animated: true)
            LoginBackend.shared.resendCodeForSignUp(username: RegisterCache.sharedTools.phone) {
                print("send code success")
                DispatchQueue.main.async {
                    let vc = ConfirmationCodeViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } fail: { msg in
                self.showFail()
            }

        }))
        present(alert, animated: true)
    }
}
