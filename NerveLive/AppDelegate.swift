//
//  AppDelegate.swift
//  NerveLive
//
//  Created by 殷聃 on 2023/12/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        addAmplify()
        changeRootViewController()
        return true
    }

    func changeRootViewController() {
        let user = LoginTools.sharedTools.userInfo()
        var rootViewController: UIViewController?
        if user.id.isEmpty { // 未注册
            rootViewController = PhoneInputViewController()
        } else {
            if (user.firstName ?? "").isEmpty || (user.lastName ?? "").isEmpty { // 未补充姓名
                rootViewController = NameInputViewController()
            } else {
                rootViewController = ViewController()
            }
        }
        if let root = rootViewController {
            let navVC: UINavigationController  = UINavigationController(rootViewController: root)
            navVC.isNavigationBarHidden = true
            self.window?.rootViewController = navVC
            self.window?.backgroundColor = .white
            self.window?.makeKeyAndVisible()
        }
    }
}

