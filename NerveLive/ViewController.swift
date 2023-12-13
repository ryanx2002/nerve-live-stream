//
//  ViewController.swift
//  NerveLive
//
//  Created by 殷聃 on 2023/12/2.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(openLiveBtn)
    }

    lazy var openLiveBtn: UIButton = {
        let closeBtn = UIButton(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT() + 44, width: K_SCREEN_WIDTH - 16 * 2, height: 60))
        closeBtn.backgroundColor = .blue
        closeBtn.setTitle("打开直播", for: .normal)
        closeBtn.addTarget(self, action: #selector(openLive), for: .touchUpInside)
        return closeBtn
    }()
    
    @objc func openLive() {
        LiveManager.shared.connectChannel()
    }
    
}

