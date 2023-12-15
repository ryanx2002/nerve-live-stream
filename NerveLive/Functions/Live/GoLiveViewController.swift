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
    }

    lazy var openLiveBtn: UIButton = {
        let closeBtn = UIButton(frame: view.bounds)
        closeBtn.backgroundColor = .clear
        closeBtn.setTitle("Go Live", for: .normal)
        closeBtn.titleLabel?.textAlignment = .center
        closeBtn.titleLabel?.font = UIFont.font(ofSize: 36, type: .Bold)
        closeBtn.addTarget(self, action: #selector(goLive), for: .touchUpInside)
        return closeBtn
    }()

    @objc func goLive() {
        LiveManager.shared.connectChannel()
    }

}
