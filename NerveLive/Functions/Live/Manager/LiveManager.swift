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
    
    /// 是否是房间主人
    var isMaster = true
    /// 频道名称
    var channelName: String? = "never-live-kvs-channel"
    ///  客户端ID
    var clientID: String = "64tkrejscnmpmsnppdbk4q9452"
    /// 区域名称
    var regionName: String = "us-east-1"
    
    // sender IDs
    var remoteSenderClientId: String?
    lazy var localSenderId: String = {
        return connectAsViewClientId
    }()
}
