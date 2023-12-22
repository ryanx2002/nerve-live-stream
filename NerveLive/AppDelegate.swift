//
//  AppDelegate.swift
//  NerveLive
//
//  Created by 殷聃 on 2023/12/2.
//

import UIKit
import AWSPinpoint

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    var pinpoint: AWSPinpoint?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        addAmplify()
        addLive()
        changeRootViewController()
        return true
    }

    func changeRootViewController() {
        let user = LoginTools.sharedTools.userInfo()
        var rootViewController: UIViewController?
        if user.id.isEmpty { // 未注册
            // rootViewController = PhoneInputViewController()
            rootViewController = StartupPageViewController()
        } else {
            debugPrint("userid:\(user.id)")
            if (user.firstName ?? "").isEmpty || (user.lastName ?? "").isEmpty { // 未补充姓名
                rootViewController = NameInputViewController()
            } else {
                if user.isMaster ?? false {
                    rootViewController = GoLiveViewController() //GoLiveViewController()
                } else {
                    rootViewController = ViewerGoLiveViewController()
                }
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
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
            self.lockOrientation(orientation)
//             if #available(iOS 16, *) {
//                 DispatchQueue.main.async {
//                     let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                         windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
//                 }
//             } else {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
//             }
        }
    }
}

