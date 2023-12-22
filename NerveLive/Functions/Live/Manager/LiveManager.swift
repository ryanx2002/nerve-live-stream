//
//  LiveManager.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import UIKit
import AWSMobileClient

/// 直播管理类
class LiveManager: NSObject {
    static let shared = LiveManager()
    private override init() {}
    
    // variables controlled by UI
    var sendAudioEnabled: Bool = true
    var signalingConnected: Bool = false
    
    // clients for WEBRTC Connection
    var signalingClient: SignalingClient?
    var webRTCClient: WebRTCClient?

    /// 频道名称
    var channelName: String? = "never-live-kvs-channel-\(LoginTools.sharedTools.userId())"
    /// 是否是房间主人
    var isMaster: Bool {
        guard let channelName = channelName else { return false }
        return channelName.hasSuffix(LoginTools.sharedTools.userId())
    }
    ///  客户端ID
    var clientID: String = "64tkrejscnmpmsnppdbk4q9452"
    /// 区域名称
    var regionName: String = "us-east-1"
    
    // sender IDs
    var remoteSenderClientId: String?
    lazy var localSenderId: String = {
        return connectAsViewClientId
    }()

    /// 进入直播间
    func enterLiveRoom() {
        var user = LoginTools.sharedTools.userInfo()
        if user.isMaster ?? false { // master 角色
            user.isLive = true
            LoginBackend.shared.updateUser(user: user) {
                debugPrint("master is Live")
            } fail: { msg in
                debugPrint("master open Live fail")
            }
        } else { // viewer角色

        }
    }

    /// 退出直播间
    func exitLiveRoom() {
        var user = LoginTools.sharedTools.userInfo()
        if user.isMaster ?? false { // master 角色
            user.isLive = false
            LoginBackend.shared.updateUser(user: user) {
                debugPrint("master is not Live")
            } fail: { msg in
                debugPrint("master close Live fail")
            }
        } else { // viewer角色

        }
    }
}
