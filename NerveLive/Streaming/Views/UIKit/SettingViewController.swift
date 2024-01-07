//
//  SettingViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/21.
//

import UIKit
import Kingfisher
import Photos
import SVProgressHUD
import Amplify
import MessageUI

/// 菜单设置页面
class SettingViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(cancelBtn)
        view.addSubview(firstLine)
        view.addSubview(flagBtn)
        view.addSubview(secondLine)
        view.addSubview(blockBtn)

        view.addSubview(deleteAccountBtn)
        view.addSubview(sixthLine)
        view.addSubview(logoutBtn)
        //view.addSubview(fifthLine)

    }


    lazy var firstLine: UIImageView = {
        let firstLine = UIImageView()
        firstLine.frame = CGRect(x: 0, y: K_NAV_HEIGHT - 0.5, width: K_SCREEN_WIDTH, height: 0.5)
        firstLine.backgroundColor = .systemGray
        return firstLine
    }()

    /// cancel
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: 20, y: K_SAFEAREA_TOP_HEIGHT(), width: 50, height: 44)
        cancelBtn.backgroundColor = .clear
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.titleLabel?.font = .font(ofSize: 14, type: .Regular)
        cancelBtn.setTitleColor(K_VIEW_WHITECOLOR, for: .normal)
        cancelBtn.contentHorizontalAlignment = .left
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        return cancelBtn
    }()

    @objc func cancelBtnClicked() {
        dismiss(animated: true)
    }

    lazy var flagBtn: UIButton = {
        let flagBtn = UIButton(type: .custom)
        flagBtn.frame = CGRect(x: 0 , y: firstLine.frame.minY, width: K_SCREEN_WIDTH, height: 50)
        flagBtn.backgroundColor = .clear
        flagBtn.setTitle("Flag", for: .normal)
        flagBtn.setTitleColor(K_VIEW_WHITECOLOR, for: .normal)
        flagBtn.titleLabel?.font = UIFont.font(ofSize: 14, type: .Regular)
        flagBtn.addTarget(self, action: #selector(flagBtnClicked), for: .touchUpInside)
        return flagBtn
    }()

    @objc func flagBtnClicked() {
        let msg = "We have received your report and will verify the situation as soon as possible and handle it promptly!"
        let alert = UIAlertController(title: "Tips", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sure", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

    lazy var secondLine: UIImageView = {
        let secondLine = UIImageView()
        secondLine.frame = CGRect(x: 0, y: CGRectGetMaxY(flagBtn.frame), width: K_SCREEN_WIDTH, height: 0.5)
        secondLine.backgroundColor = .systemGray
        return secondLine
    }()

    lazy var blockBtn: UIButton = {
        let blockBtn = UIButton(type: .custom)
        blockBtn.frame = CGRect(x: 0 , y: secondLine.frame.minY, width: K_SCREEN_WIDTH, height: 50)
        blockBtn.backgroundColor = .clear
        blockBtn.setTitle("Block", for: .normal)
        blockBtn.setTitleColor(K_VIEW_WHITECOLOR, for: .normal)
        blockBtn.titleLabel?.font = UIFont.font(ofSize: 14, type: .Regular)
        blockBtn.addTarget(self, action: #selector(blockBtnClicked), for: .touchUpInside)
        return blockBtn
    }()

    @objc func blockBtnClicked() {
        let user = LoginTools.sharedTools.userInfo()
        let name = "\(user.lastName ?? "") \(user.firstName ?? "")"
        let alert = UIAlertController(title: "Tips", message: "User \(name) has been blocked, Any future updates from this anchor will be blocked for you!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sure", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

    lazy var deleteAccountBtn: UIButton = {
        let deleteAccountBtn = UIButton(type: .custom)
        deleteAccountBtn.frame = CGRect(x: 0 , y: K_SCREEN_HEIGHT - K_SAFEAREA_BOTTOM_HEIGHT() - 50, width: K_SCREEN_WIDTH, height: 50)
        deleteAccountBtn.backgroundColor = .clear
        deleteAccountBtn.setImage(UIImage(named: "delete_account"), for: .normal)
        deleteAccountBtn.addTarget(self, action: #selector(deleteAccountBtnClicked), for: .touchUpInside)
        return deleteAccountBtn
    }()

    /// 注销账户点击事件
    @objc func deleteAccountBtnClicked() {
        SVProgressHUD.show()
        let userId = LoginTools.sharedTools.userId()
        LoginBackend.shared.deleteUser(model: User(id: userId)) {
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                getAppDelegate().changeRootViewController()
            }
        } fail: { msg in
            SVProgressHUD.showError(withStatus: msg)
        }
    }

    lazy var sixthLine: UIImageView = {
        let sixthLine = UIImageView()
        sixthLine.frame = CGRect(x: 0, y: CGRectGetMinY(deleteAccountBtn.frame), width: K_SCREEN_WIDTH, height: 0.5)
        sixthLine.backgroundColor = .systemGray
        return sixthLine
    }()

    lazy var logoutBtn: UIButton = {
        let logoutBtn = UIButton(type: .custom)
        logoutBtn.frame = CGRect(x: 0 , y: CGRectGetMaxY(sixthLine.frame) - 50, width: K_SCREEN_WIDTH, height: 50)
        logoutBtn.backgroundColor = .clear
        logoutBtn.setImage(UIImage(named: "logout_account"), for: .normal)
        logoutBtn.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
        return logoutBtn
    }()

    /// 退出登录点击事件
    @objc func logoutBtnClicked() {
        SVProgressHUD.show()
        LoginBackend.shared.signOut {
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                getAppDelegate().changeRootViewController()
            }
        } fail: {
            SVProgressHUD.showError(withStatus: "Logout Fail")
        }
    }

    lazy var fifthLine: UIImageView = {
        let fifthLine = UIImageView()
        fifthLine.frame = CGRect(x: 0, y: CGRectGetMinY(logoutBtn.frame), width: K_SCREEN_WIDTH, height: 0.5)
        fifthLine.backgroundColor = .systemGray
        return fifthLine
    }()

}
