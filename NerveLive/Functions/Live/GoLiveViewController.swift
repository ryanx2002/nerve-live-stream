//
//  GoLiveViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/15.
//

import UIKit
import SVProgressHUD

/// master角色前往直播页面
class GoLiveViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(menuBtn)
        view.addSubview(openLiveBtn)
        // view.addSubview(idLabel)
        getAppDelegate().mainRegisterRemote()
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
    
    lazy var menuBtn: UIButton = {
        let menuBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 22 - 48, y: K_SAFEAREA_TOP_HEIGHT(), width: 48, height: 48))
        menuBtn.backgroundColor = .clear
        menuBtn.setImage(UIImage(named: "icon_line_menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuBtnClick), for: .touchUpInside)
        return menuBtn
    }()

    @objc func menuBtnClick() {
        let vc = SettingViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}
