//
//  ConfirmationCodeViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit
import SVProgressHUD
import Amplify

let HIGHLIGHT_TEXT_BG = "#ffffff"
let DEFAUT_TEXT_BG = "#4B4B4B"

class ConfirmationCodeViewController: BaseViewController {
    
    var isLogin: Bool = false // is Login? default false(signUp)
    
    @IBOutlet weak var DescTitle:UILabel!
    @IBOutlet weak var YourPhoneTitle:UILabel!
    @IBOutlet weak var CodeArea:UIView!
    var CodeValue:String?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIViewSetFrameX(view: DescTitle, x: 0)
        UIViewSetFrameWidth(view: DescTitle, width: K_SCREEN_WIDTH)
        self.DescTitle.textAlignment = .center
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.DescTitle.attributedText = StringUtils.TextWithBorder(font: 16, text: "Enter the code we just texted")

        // 创建一个NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: "you at \(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)")

        // 添加红色边框
        let redBorderColor = UIColor.red
        attributedString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5), range: NSRange(location: 0, length: "you at ".count))
        attributedString.addAttribute(NSAttributedString.Key.strokeWidth, value: -4.0, range: NSRange(location: 0, length: "you at ".count))
        attributedString.addAttribute(.font, value: UIFont.font(ofSize: 20, type: .Regular), range: NSRange(location: 0, length: "you at ".count))
        // 添加下划线
        let underlineStyle = NSUnderlineStyle.single.rawValue
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineStyle, range: NSRange(location: 0, length: attributedString.length))

        // 将NSAttributedString赋给UILabel的attributedText属性
        self.YourPhoneTitle.attributedText = attributedString
        self.YourPhoneTitle.font = UIFont.systemFont(ofSize: 16)
        
        self.CodeArea.addSubview(editView)
        editView.venmoEditDidChanged = { value in
            print("当前输入内容:\(value)")
        }
        editView.venmoEditFinished = { value in
            print("当前输入内容:\(value)")
            if(value.count == 6){
                self.CodeValue = value
                RegisterCache.sharedTools.verificationCode = value
                if self.isLogin {
                    self.login()
                } else {
                    self.signUp()
                }
            }
        }
    }

    lazy var editView: VenmoEditConfirmationView = {
        let editView = VenmoEditConfirmationView()
        editView.frame = CGRect(x: 50, y: 0, width: K_SCREEN_WIDTH - 50 * 2, height: 80)
        editView.itemCount = 6
        editView.itemSize = CGSize(width: 50, height: 80)
        return editView
    }()

    func login() {
        Amplify.Auth.confirmResetPassword(for: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)", with: RegisterCache.sharedTools.password, confirmationCode: self.CodeValue ?? "") { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    SVProgressHUD.show()
                }
                LoginBackend.shared.login(userName: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)", pwd: RegisterCache.sharedTools.password) {
                    print("登录成功")
                    //LiveManager.shared.singIn()
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        let name = NameInputViewController()
                        self.navigationController?.pushViewController(name, animated: true)
                    }
                } fail: { error in
                    print(error)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showError(withStatus: error.debugDescription)
                    }
                } confirmSignUp: {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                }
            case .failure(let error):
                let err = "\(error)"
                if err.contains("Invalid verification code provided") {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Tips", message: "Invalid verification code provided, please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Sure", style: .default))
                        self.present(alert, animated: true)
                    }
                }
                print("An error occurred while confirmResetPassword \(error)")
            }
        }
    }
    
    func signUp(){
        SVProgressHUD.show()
        LoginBackend.shared.confirmSignUp(for: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)", with: self.CodeValue ?? "") {
            LoginBackend.shared.login(userName: "\(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)", pwd: RegisterCache.sharedTools.password) {
                print("登录成功")
                //LiveManager.shared.singIn()
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let name = NameInputViewController()
                    self.navigationController?.pushViewController(name, animated: true)
                }
            } fail: { error in
                print(error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: error.debugDescription)
                }
            } confirmSignUp: {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        } fail: { error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Invalid verification code provided, please try again.")
            }
        }
    }

}

