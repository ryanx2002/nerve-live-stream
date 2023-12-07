//
//  ConfirmationCodeViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit
import SVProgressHUD

let HIGHLIGHT_TEXT_BG = "#ffffff"
let DEFAUT_TEXT_BG = "#4B4B4B"

class ConfirmationCodeViewController: BaseViewController {
    @IBOutlet weak var DescTitle:UILabel!
    @IBOutlet weak var YourPhoneTitle:UILabel!
    @IBOutlet weak var CodeArea:UIView!
    var CodeValue:String?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIViewSetFrameWidth(view: DescTitle, width: 260)
        UIViewSetFrameCenterX(view: DescTitle, x: K_SCREEN_WIDTH / 2.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.DescTitle.attributedText = StringUtils.TextWithBorder(font: 20, text: "Enter the code we just texted")

        // 创建一个NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: "you at \(RegisterCache.sharedTools.countryCode)\(RegisterCache.sharedTools.phone)")

        // 添加红色边框
        let redBorderColor = UIColor.red
        attributedString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5), range: NSRange(location: 0, length: "you at ".count))
        attributedString.addAttribute(NSAttributedString.Key.strokeWidth, value: -4.0, range: NSRange(location: 0, length: "you at ".count))

        // 添加下划线
        let underlineStyle = NSUnderlineStyle.single.rawValue
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: underlineStyle, range: NSRange(location: "you at ".count+1, length: attributedString.length-"you at ".count-1))

        // 将NSAttributedString赋给UILabel的attributedText属性
        self.YourPhoneTitle.attributedText = attributedString
        
        self.CodeArea.addSubview(editView)
        editView.venmoEditDidChanged = { value in
            print("当前输入内容:\(value)")
        }
        editView.venmoEditFinished = { value in
            print("当前输入内容:\(value)")
            if(value.count == 6){
                self.CodeValue = value
                RegisterCache.sharedTools.verificationCode = value
                self.login()
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

    func login(){
//        let name = NameInputViewController()
//        navigationController?.pushViewController(name, animated: true)
        SVProgressHUD.show()
        LoginBackend.shared.confirmSignUp(for: RegisterCache.sharedTools.phone, with: self.CodeValue ?? "") {
            LoginBackend.shared.login(userName: RegisterCache.sharedTools.phone, pwd: RegisterCache.sharedTools.password) {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
//                    let homeVC:SignUpSucViewController = SignUpSucViewController()
//                    let nav = UINavigationController(rootViewController: homeVC)
//                    nav.isNavigationBarHidden = true
//                    self.changeRootController(controller: nav)
                }
                print("登录成功")
            } fail: { error in
                print(error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            } confirmSignUp: {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        } fail: { error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }

}

