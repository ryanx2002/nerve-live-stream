//
//  AuditLoginViewController.swift
//  NerveLive
//
//  Created by wbx on 16/12/2023.
//

import UIKit
import Amplify
import SVProgressHUD

/// App Store审核登陆
class AuditLoginViewController: BaseViewController {

    var isMaster = false // 登陆账号是否是master身份
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textLabel)
        view.addSubview(passwordTF)
        view.addSubview(signUpBtn)
        Amplify.Auth.signOut { _ in

        }
    }
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: CGRect(x: 0, y: 192, width: K_SCREEN_WIDTH, height: 20))
        textLabel.font = UIFont.font(ofSize: 16, type: .Regular)
        textLabel.text = "Please enter password"
        textLabel.textColor = UIColor.hexColorWithAlpha(color: "#FF00E5", alpha: 1)
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    lazy var passwordTF: UITextField = {
        let passwordTF = UITextField(frame: CGRect(x: 40, y: 260, width: K_SCREEN_WIDTH - 40 * 2, height: 53))
        let placeholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.hexColorWithAlpha(color: "A9A9A9", alpha: 1)])
        passwordTF.attributedPlaceholder = placeholder
        passwordTF.font = UIFont.font(ofSize: 40, type: .Regular)
        passwordTF.isSecureTextEntry = true
        passwordTF.textAlignment = .center
        passwordTF.textColor = UIColor.hexColorWithAlpha(color: "F9F9F9", alpha: 1)
        passwordTF.returnKeyType = .done
        return passwordTF
    }()
    
    lazy var signUpBtn: UIButton = {
        let signUpBtn = UIButton(type: .custom)
        signUpBtn.frame = CGRect(x: (K_SCREEN_WIDTH - 80) / 2, y: passwordTF.frame.maxY + 60, width: 80, height: 50)
        signUpBtn.layer.cornerRadius = 6
        signUpBtn.layer.masksToBounds = true
        signUpBtn.layer.borderWidth = 1
        signUpBtn.layer.borderColor = UIColor.hexColorWithAlpha(color: "#FF00E5", alpha: 1).cgColor
        signUpBtn.setTitle("Sign Up", for: .normal)
        signUpBtn.setTitleColor(UIColor.hexColorWithAlpha(color: "#FF00E5", alpha: 1), for: .normal)
        signUpBtn.addTarget(self, action: #selector(signUpBtnClick), for: .touchUpInside)
        return signUpBtn
    }()
    
    @objc func signUpBtnClick() {
        passwordTF.resignFirstResponder()
        if (passwordTF.text ?? "").count <= 0 {
            SVProgressHUD.showError(withStatus: "Please enter password")
            return
        }
        /// +19452007009  +17048901338
        SVProgressHUD.show()
        let phone = self.isMaster ? "+17048901338" : "+19452007009"
        LoginBackend.shared.login(userName: phone, pwd: RegisterCache.sharedTools.password) {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                getAppDelegate().changeRootViewController()
                LiveManager.shared.singIn()
            }
        } fail: { msg in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        } confirmSignUp: {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
}
