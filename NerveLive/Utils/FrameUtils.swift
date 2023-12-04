//
//  FrameUtils.swift
//  Nerve
//
//  Created by wbx on 2023/9/13.
//

import UIKit

/// 入口类
func getAppDelegate() -> AppDelegate {
    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    return delegate
}

/// UIWindow
public func  getAppWindow() -> UIWindow {
    guard let keyWindow =  getAppDelegate().window else { return UIWindow.init() }
    return keyWindow
}

/// 刘海屏判断
public func iPhoneX() -> Bool {
    var iPhoneXSeries: Bool = false
    if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
        return iPhoneXSeries
    }
    if #available(iOS 11.0, *) {
        guard let keyWindow =  getAppDelegate().window else { return false }
        if keyWindow.safeAreaInsets.bottom > 0.0 {
            iPhoneXSeries = true
        }
    }
    return iPhoneXSeries
}

/// 上部安全区高度
public func K_SAFEAREA_TOP_HEIGHT() -> CGFloat {
    if iPhoneX() {
        if #available(iOS 11.0, *) {
            return  getAppWindow().safeAreaInsets.top
        } else {
            return 0
        }
    } else {
        return 0
    }
}

/// 下部安全区高度
public func K_SAFEAREA_BOTTOM_HEIGHT() -> CGFloat {
    if iPhoneX() {
        if #available(iOS 11.0, *) {
            return  getAppWindow().safeAreaInsets.bottom
        } else {
            return 0
        }
    } else {
        return 0
    }
}

/// 获取UIScreen
/// - Returns: UIScreen
public func K_SCREEN() -> UIScreen {
    if #available(iOS 13.0, *) {
        guard let mainScreen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen else {
            return UIScreen.main
        }
        return mainScreen
    } else {
        return UIScreen.main
    }
}

/// 手机系统
public let iOS7: Bool = ((UIDevice.current.systemVersion as NSString).floatValue >= 7.0 ? true : false)

/// 屏幕宽度(不适应横竖屏)
public let K_SCREEN_WIDTH: CGFloat = K_SCREEN().bounds.size.width

/// 屏幕高度(不适应横竖屏)
public let K_SCREEN_HEIGHT: CGFloat = K_SCREEN().bounds.size.height

/// 窗口宽度(适应横竖屏) 必须使用函数，不能使用let/var
public func K_WINDOW_WIDTH() -> CGFloat {
    return  getAppWindow().bounds.size.width // 也可以 return K_SCREEN().bounds.size.width
}

/// 窗口高度(适应横竖屏) 必须使用函数，不能使用let/var
public func K_WINDOW_HEIGHT() -> CGFloat {
    return  getAppWindow().bounds.size.height // 也可以 return K_SCREEN().bounds.size.height
}

/// 状态栏高度
public let K_STATUSBAR_HEIGHT: CGFloat = (iOS7 ? 0 : 20)

/// iPhoneX的导航栏高度
public let K_IPHONEX_NAV_HEIGHT: CGFloat = (K_SAFEAREA_TOP_HEIGHT() + 44)

// 视频状态栏
public let K_Video_STATUS_HEIGHT: CGFloat = K_SAFEAREA_TOP_HEIGHT() + K_STATUSBAR_HEIGHT

/// 导航栏高度
public let K_NAV_HEIGHT: CGFloat = (iPhoneX() ? K_IPHONEX_NAV_HEIGHT : (iOS7 ? 64.0 : 44.0))

/// tabBar高度
public let K_TABBAR_HEIGHT: CGFloat = 49.0

/// 整体App背景视图色
public let K_VIEW_BACKGROUNDCOLOR = UIColor(32, 30, 30, 1)
public let K_VIEW_BLACKCOLOR = UIColor(9, 9, 9)
public let K_VIEW_WHITECOLOR = UIColor(242, 249, 249)

/// frame setting
public func UIViewSetFrameOrigin(view: UIView, origin: CGPoint) {
    view.frame = CGRect(x: origin.x, y: origin.y, width: view.frame.size.width, height: view.frame.size.height)
}

public func UIViewSetFrameSize(view: UIView, size: CGSize) {
    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: size.width, height: size.height)
}

public func UIViewSetFrameX(view: UIView, x: CGFloat) {
    view.frame = CGRect(x: x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
}

public func UIViewSetFrameY(view: UIView, y: CGFloat) {
    view.frame = CGRect(x: view.frame.origin.x, y: y, width: view.frame.size.width, height: view.frame.size.height)
}

public func UIViewSetFrameWidth(view: UIView, width: CGFloat) {
    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: view.frame.size.height)
}

public func UIViewSetFrameHeight(view: UIView, height: CGFloat) {
    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: height)
}

public func UIViewSetFrameCenterX(view: UIView, x: CGFloat) {
    var center: CGPoint = view.center
    center.x = x
    view.center = center
}

public func UIViewSetFrameCenterY(view: UIView, y: CGFloat) {
    var center: CGPoint = view.center
    center.y = y
    view.center = center
}
let kAppNotificationAllow = "kAppNotificationAllow" // Nerve 通知授权key
let kRankingPopView = "kRankingPopView" // 排行榜弹窗Key
/// App Store Url
let kAppStoreUrl = "https://apps.apple.com/app/6468271439"
/// invited user Url
func kInviteUrl(sender: String, to: String) -> String {
    var url = "https://nerve-invite.vercel.app/invite/\(sender)+++\(to)"
    url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    return url
}

/// 是否是管理员账户
//func isAdmin() -> Bool {
//    let admintList = ["ryanx2002@gmail.com", "ralongbottom@gmail.com", "1051075840@qq.com"]
//    if admintList.contains(LoginTools.sharedTools.userInfo().email) { // 是管理员邮箱
//        return true
//    }
//    return false
//}

/// 管理员账户id列表
let adminIdList = ["005de088-b042-4933-bfa1-5ba16a4a6661", "e7f5dda6-945c-4485-8c1e-39c094fed832", "90effd3a-f125-47da-abb1-1fabb748aec7"]
