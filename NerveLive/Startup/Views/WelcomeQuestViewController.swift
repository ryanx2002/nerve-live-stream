//
//  WelcomeQuestViewController.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/30/23.
//

import Foundation
import UIKit
import SwiftUI

class WelcomeQuestViewController : BaseViewController {
    /*
    override func changeRootController(controller:UIViewController){
        var transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.type = CATransitionType.reveal
        keyWindow?.layer.add(transition, forKey: "animation")
        keyWindow?.rootViewController = controller;
    }*/
    
    lazy var welcomeToQuestImage: UIImageView = {
        let logoImg = UIImageView(frame: CGRect(x: (K_SCREEN_WIDTH - 339) / 2.0, y: 280, width: 339, height: 146))
        logoImg.image = UIImage(named: "welcome_quest")
        return logoImg
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(welcomeToQuestImage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


// preview stuff. note Amplify functions cause preview to crash

struct WelcomeView: UIViewControllerRepresentable {
    typealias UIViewControllerType = WelcomeQuestViewController
    func makeUIViewController(context: Context) -> WelcomeQuestViewController {
            let vc = WelcomeQuestViewController()
            return vc
        }
    func updateUIViewController(_ uiViewController: WelcomeQuestViewController, context: Context) {
        }
    }

struct WelcomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return WelcomeView()
    }
}
