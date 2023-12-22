//
//  AppDelegate+Push.swift
//  NerveLive
//
//  Created by wbx on 2023/12/22.
//

import Foundation
import AWSPinpoint

extension AppDelegate {

    /// 注册推送
    func registerRemote() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .badge, .alert, .carPlay]) { (success, _) in
            if success {
                print("授权成功")
                UserDefaults.standard.setValue("1", forKey: kAppNotificationAllow)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("授权失败")
            }
            DispatchQueue.main.async {
                self.changeRootViewController()
            }
        }
    }

    func mainRegisterRemote() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .badge, .alert, .carPlay]) { (success, _) in
            if success {
                print("授权成功")
                UserDefaults.standard.setValue("1", forKey: kAppNotificationAllow)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("授权失败")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("DeviceToken注册成功:\(deviceTokenString)")
        var user = LoginTools.sharedTools.userInfo()
        user.deviceToken = deviceTokenString
        if !user.id.isEmpty {
            LoginBackend.shared.updateUser(user: user) {

            } fail: { msg in

            }
        }
        // Register the device token with Pinpoint as the endpoint for this user
        pinpoint?.notificationManager
            .interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("DeviceToken注册失败\(error)")
    }

    func addPinPoint(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // reset icon badege is 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Instantiate Pinpoint
        let pinpointConfiguration = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        // Set debug mode to use APNS sandbox, make sure to toggle for your production app
        pinpointConfiguration.debug = true
        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
        // Present the user with a request to authorize push notifications
        mainRegisterRemote()
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 当应用在前台时收到推送通知时会调用
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("通知1==:\(notification.request.content.userInfo)")
        // Handle foreground push notifications
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(notification.request.content.userInfo)
        // 处理收到的通知
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
    }

    // 当用户点击通知进入应用时会调用
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("通知2==:\(response.notification.request.content.userInfo)")
        // Handle background and closed push notifications
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(response.notification.request.content.userInfo)
        // 处理用户点击通知后的操作
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("通知3==:\(userInfo)")
        if application.applicationState != .active {
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
        // Pass this remote notification event to pinpoint SDK to keep track of notifications produced by AWS Pinpoint campaigns.
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(userInfo)
        // 处理远程推送通知
        // 在这里你可以获取到推送通知的信息
        completionHandler(.newData)
    }
}
