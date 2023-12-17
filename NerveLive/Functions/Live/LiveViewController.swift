//
//  LiveViewController.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import UIKit
import AWSKinesisVideo
import WebRTC

class LiveViewController: BaseViewController {

    var mediaServerEndPoint: String?

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(localVideoView)
        view.addSubview(closeBtn)
        
        if !LiveManager.shared.isMaster {
            // In viewer mode send offer once connection is established
            if let webRTCClient = LiveManager.shared.webRTCClient {
                webRTCClient.offer { sdp in
                    if let signalingClient = LiveManager.shared.signalingClient {
                        signalingClient.sendOffer(rtcSdp: sdp, senderClientid: LiveManager.shared.localSenderId)
                    }
                }
            }
        }
        if mediaServerEndPoint == nil {
            //self.joinStorageButton?.isHidden = true
        }
        
        #if arch(arm64)
        // Using metal (arm64 only)
        let localRenderer = RTCMTLVideoView(frame: localVideoView.frame)
        let remoteRenderer = RTCMTLVideoView(frame: view.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.backgroundColor = K_VIEW_WHITECOLOR
        #else
        // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: localVideoView.frame)
        let remoteRenderer = RTCEAGLVideoView(frame: view.frame)
        remoteRenderer.backgroundColor = K_VIEW_WHITECOLOR
        #endif

        LiveManager.shared.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer)
        LiveManager.shared.webRTCClient?.renderRemoteVideo(to: remoteRenderer)

        embedView(localRenderer, into: localVideoView)
        embedView(remoteRenderer, into: view)
        view.sendSubviewToBack(remoteRenderer)
        /// 如果是master隐藏对方视频内容,  如果是viewer隐藏本地视频内容
        if LiveManager.shared.isMaster {
            remoteRenderer.isHidden = true
        } else {
            localRenderer.isHidden = true
        }
    }

    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))
        containerView.layoutIfNeeded()
    }

    @objc func closeLive() {
        LiveManager.shared.webRTCClient?.shutdown()
        LiveManager.shared.signalingClient?.disconnect()
        dismiss(animated: true)
    }
    
//    @IBAction func joinStorageSession(_: Any) {
//        print("button pressed")
//        joinStorageButton?.isHidden = true
//    }
    
    lazy var localVideoView: UIView = {
        // let localVideoView = UIView(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT() + 16, width: 200, height: 200))
        let localVideoView = UIView(frame: view.bounds) // 全屏展示
        return localVideoView
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 44 - 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 44, height: 44))
        closeBtn.backgroundColor = .clear
        closeBtn.setImage(UIImage(named: "nav_close_back"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeLive), for: .touchUpInside)
        return closeBtn
    }()

}