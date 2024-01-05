//
//  AppDelegate.swift
//  NerveLive
//
//  Created by 殷聃 on 2023/12/2.
//

import UIKit
import AWSPinpoint
import Amplify
import AmplifyPlugins
import Network

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    var pinpoint: AWSPinpoint?
    var monitor: NWPathMonitor?
    var isStream = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        addAmplify()
        addLive()
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connection OK")
                /*
                DispatchQueue.main.async {
                    if self.window?.rootViewController.self === StreamerOfflineViewController.self {
                        self.changeRootViewController()
                    }
                }
                 */
            } else {
                DispatchQueue.main.async {
                    let root = StreamerOfflineViewController()
                    root.wifiBad = true
                    let navVC: UINavigationController  = UINavigationController(rootViewController: root)
                    navVC.isNavigationBarHidden = true
                    self.window?.rootViewController = navVC
                    self.window?.backgroundColor = .black
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        monitor?.start(queue: DispatchQueue(label: "NetworkMonitor"))
        
        changeRootViewController()
        
        return true
    }
    
    func changeToViewController(root : UIViewController) {
        let navVC: UINavigationController  = UINavigationController(rootViewController: root)
        navVC.isNavigationBarHidden = true
        self.window?.rootViewController = navVC
        self.window?.backgroundColor = .black
        self.window?.makeKeyAndVisible()
    }

    func changeRootViewController() {
        let user = LoginTools.sharedTools.userInfo()
        var rootViewController: UIViewController?
        if user.id.isEmpty { // 未注册
            // rootViewController = PhoneInputViewController()
            rootViewController = StartupPageViewController()
        } else {
            debugPrint("userid:\(user.id)\n\(user.firstName ?? "none") \(user.lastName ?? "none")")
            if (user.firstName ?? "").isEmpty || (user.lastName ?? "").isEmpty { // 未补充姓名
                rootViewController = NameInputViewController()
            } 
            // TODO(matt): send them to login page. logic to decide where 
            else if (LoginTools.sharedTools.userInfo().phone!) == "+17048901338" {
                rootViewController = GoLiveViewController()
            }
            else if isStream {
                //rootViewController = TwitchViewController()
                rootViewController = LiveViewController() //StreamerOfflineViewController()//LiveViewController() //GoLiveViewController()
                //rootViewController = StreamerOfflineViewController()
            } else {
                rootViewController = StreamerOfflineViewController()
            }
        }
        if let root = rootViewController {
            let navVC: UINavigationController  = UINavigationController(rootViewController: root)
            navVC.isNavigationBarHidden = true
            self.window?.rootViewController = navVC
            self.window?.backgroundColor = .black
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

