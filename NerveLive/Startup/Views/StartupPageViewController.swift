//
//  StartupPageViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/19.
//

import UIKit
import YYText
import SwiftUI

/// 启动页
class StartupPageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoImg)
        //view.addSubview(nerveLogo)
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
        logoImg.image = UIImage(named: "nerve")
        return logoImg
    }()
    
    lazy var nerveLogo: UIView = {
        
        let container = UIView(frame : CGRect(x: (K_SCREEN_WIDTH - 385) / 2.0, y: 338, width: 400, height: 92))
        /*
        let nerveLogo = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 92))
        //let attributedString = StringUtils.TextWithBorder(font: 76, text: "NERVE")
        
        
        // 创建白色字体属性
        let whiteColor = UIColor.white
        let whiteFontAttribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: whiteColor,
            NSAttributedString.Key.font: UIFont(name: "Inter-Light", size: 92)

        ]

        // 创建红色描边属性
        let redColor = UIColor.red
        let redStrokeAttribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5).cgColor,
            NSAttributedString.Key.strokeWidth: -4.0, // 负值表示描边
            NSAttributedString.Key.foregroundColor: whiteColor, // 设置字体颜色，可以和白色保持一致
            NSAttributedString.Key.font : UIFont(name: "Inter-Light", size: 92)
        ]

        // 创建富文本字符串
        let attributedText = NSMutableAttributedString(string: "NERVE", attributes: whiteFontAttribute)

        // 应用描边属性
        attributedText.addAttributes(redStrokeAttribute, range: NSRange(location: 0, length: 5))
        
        attributedText.addAttributes([NSAttributedString.Key.kern: 19], range: NSRange(location: 0, length: 5))
        nerveLogo.attributedText = attributedText
        container.addSubview(nerveLogo)
         */
        /*
        nerveLogo.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        nerveLogo.font = UIFont(name: "Inter-Light", size: 76)
        // Line height: 91.98 pt
        nerveLogo.textAlignment = .center
        nerveLogo.attributedText = NSMutableAttributedString(string: "NERVE", attributes: [NSAttributedString.Key.kern: 19])
        container.addSubview(nerveLogo)
        
        nerveLogo.layer.shadowColor = UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5).cgColor
        nerveLogo.layer.shadowRadius = 8
        nerveLogo.layer.shadowOpacity = 1
        nerveLogo.layer.shadowOffset = CGSize(width: 0, height: 10)
        nerveLogo.layer.masksToBounds = false
        nerveLogo.translatesAutoresizingMaskIntoConstraints = false
        */
         
        //let shadowPath0 = UIBezierPath(roundedRect: container.bounds, cornerRadius: 0)
        //nerveLogo.layer.shadowPath = shadowPath0.cgPath

        
        /*
        var shadows = UIView(frame: nerveLogo.frame)
        shadows.clipsToBounds = false
        nerveLogo.addSubview(shadows)
        
        
        layer0.shadowColor = UIColor(red: 1, green: 0, blue: 0.898, alpha: 0.5).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 8
        layer0.shadowOffset = CGSize(width: 0, height: 8)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        */
        return container
    }()

    lazy var playBtn: UIButton = {
        let playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: (K_SCREEN_WIDTH - 120) / 2, y: K_SCREEN_HEIGHT - 300, width: 120, height: 65)
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


// preview stuff. note Amplify functions cause preview to crash

struct StartupView: UIViewControllerRepresentable {
    typealias UIViewControllerType = StartupPageViewController
    func makeUIViewController(context: Context) -> StartupPageViewController {
            let vc = StartupPageViewController()
            return vc
        }
    func updateUIViewController(_ uiViewController: StartupPageViewController, context: Context) {
        }
    }

struct StartupViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return StartupView()
    }
}
