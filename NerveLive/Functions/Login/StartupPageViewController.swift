//
//  StartupPageViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/19.
//

import UIKit
import YYText

/// 启动页
class StartupPageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoImg)
        view.addSubview(playBtn)
        view.addSubview(agreeLabel)

        LoginBackend.shared.signOut {
            print("登出成功")
        } fail: {
            print("登出失败")
        }
        
        getAppDelegate().mainRegisterRemote()
    }

    lazy var logoImg: UIImageView = {
        let logoImg = UIImageView(frame: CGRect(x: (K_SCREEN_WIDTH - 339) / 2.0, y: 338, width: 339, height: 79))
        logoImg.image = UIImage(named: "icon_quest")
        return logoImg
    }()

    lazy var playBtn: UIButton = {
        let playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: (K_SCREEN_WIDTH - 120) / 2, y: 571 + 100, width: 120, height: 65)
        playBtn.backgroundColor = .clear
        playBtn.setImage(UIImage(named: "icon_play"), for: .normal)
        playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        return playBtn
    }()

    @objc func playBtnClick() {
        DispatchQueue.main.async {
            let nameInputVc = PhoneInputViewController();
            self.navigationController?.pushViewController(nameInputVc, animated: true)
        }
    }

    // MARK: 隐私条款 服务条款
    private lazy var agreeLabel: YYLabel = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        style.alignment = .center
        let text = "By tapping “Play”, you’re accepting the Terms and Privacy Policy.\nClick “Terms” or “Privacy Policy” to view them."
        let content = NSMutableAttributedString(string: text)
        content.yy_setFont(FONT(8), range: NSRange(location: 0, length: text.count))
        content.yy_setParagraphStyle(style, range: NSRange(location: 0, length: text.count))
        content.yy_setColor(.white, range: NSRange(location: 0, length: text.count))

        let range1: NSRange = text.nsRange(from: text.range(of: "“Terms”")!)
        content.yy_setTextHighlight(range1, color: .white, backgroundColor: nil) { (_, _, _, _) in
            let vc = WebViewController()
            vc.urlString = "https://sites.google.com/view/nerve-terms-of-service/home"
            self.present(vc, animated: true)
        }

        let range2: NSRange = text.nsRange(from: text.range(of: "“Privacy Policy”")!)
        content.yy_setTextHighlight(range2, color: .white, backgroundColor: nil) { (_, _, _, _) in
            let vc = WebViewController()
            vc.urlString = "https://sites.google.com/view/nerve-privacy-policy/home"
            self.present(vc, animated: true)
        }

        let label = YYLabel(frame: CGRect(x: 0, y: playBtn.frame.maxY + 18, width: K_SCREEN_WIDTH, height: 40))
        label.backgroundColor = .clear
        label.font = FONT(8)
        label.textColor = .white
        label.numberOfLines = 0
        label.textVerticalAlignment = .center
        label.textAlignment = .center
        label.attributedText = content
        label.sizeToFit()
        UIViewSetFrameCenterX(view: label, x: K_SCREEN_WIDTH / 2.0)
        return label
    }()
}
