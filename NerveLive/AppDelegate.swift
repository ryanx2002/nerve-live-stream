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
        let firstVC = PhoneInputViewController()
        let navVC: UINavigationController  = UINavigationController(rootViewController: firstVC)
        navVC.isNavigationBarHidden = true
        self.window?.rootViewController = navVC
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
}

