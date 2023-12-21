//
//  GoLiveViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/15.
//

import UIKit
import SVProgressHUD

/// 前往直播页面
class GoLiveViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(openLiveBtn)
        // view.addSubview(idLabel)
        view.addSubview(logoutBtn)
    }

    lazy var openLiveBtn: UIButton = {
        //let width = (374.0 * 61.0) / 183.0
        let width = (700.0 * 61.0) / 183.0
        let openLiveBtn = UIButton(frame: CGRect(x: (K_SCREEN_WIDTH - width) / 2.0, y: (K_SCREEN_HEIGHT - 61) / 2.0, width: width, height: 61))
        openLiveBtn.backgroundColor = .clear
        //openLiveBtn.setTitle("Go Live", for: .normal)
        openLiveBtn.setTitle("Stream Now", for: .normal)
        openLiveBtn.titleLabel?.textAlignment = .center
        openLiveBtn.titleLabel?.font = UIFont.font(ofSize: 36, type: .Bold)
        //openLiveBtn.setImage(UIImage(named: "icon_go_live"), for: .normal)
        openLiveBtn.addTarget(self, action: #selector(goLive), for: .touchUpInside)
        return openLiveBtn
    }()

    @objc func goLive() {
        LiveManager.shared.connectChannel()
    }
    
    lazy var idLabel: UILabel = {
        let idLabel = UILabel(frame: CGRect(x: 0, y: K_SCREEN_HEIGHT - K_SAFEAREA_BOTTOM_HEIGHT() - 20, width: K_SCREEN_WIDTH, height: 20))
        idLabel.backgroundColor = .clear
        idLabel.font = .systemFont(ofSize: 16)
        idLabel.textColor = .white
        idLabel.textAlignment = .center
        idLabel.text = LoginTools.sharedTools.userId()
        return idLabel
    }()

    lazy var logoutBtn: UIButton = {
        let logoutBtn = UIButton(type: .custom)
        logoutBtn.frame = CGRect(x: 0 , y: K_SCREEN_HEIGHT - K_SAFEAREA_BOTTOM_HEIGHT() - 50, width: K_SCREEN_WIDTH, height: 50)
        logoutBtn.backgroundColor = .clear
        logoutBtn.setImage(UIImage(named: "logout_account"), for: .normal)
        logoutBtn.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
        return logoutBtn
    }()

    /// 退出登录点击事件
    @objc func logoutBtnClicked() {
        SVProgressHUD.show()
        LoginBackend.shared.signOut {
            LiveManager.shared.signOut()
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                getAppDelegate().changeRootViewController()
            }
        } fail: {
            SVProgressHUD.showError(withStatus: "Logout Fail")
        }
    }

}
