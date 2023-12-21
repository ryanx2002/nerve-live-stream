//
//  BaseViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/10.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_VIEW_BACKGROUNDCOLOR
        navigationController?.delegate = self

        if navigationController != nil {
            /**
             * 重设侧滑返回手势代理
             */
            if (navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)))! {
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                navigationController?.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return navigationController.interactivePopGestureRecognizer?.delegate as? UIViewControllerInteractiveTransitioning
    }
    
    func changeRootController(controller:UIViewController){
        let transtition = CATransition()
        transtition.duration = 0.5
        transtition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        keyWindow?.layer.add(transtition, forKey: "animation")
        keyWindow?.rootViewController = controller;
    }

    deinit {
        SVProgressHUD.dismiss()
    }
}
