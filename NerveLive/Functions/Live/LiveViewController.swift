//
//  LiveViewController.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import UIKit
import AWSKinesisVideo
import WebRTC
import SwiftUI
import SVProgressHUD

class LiveViewController: BaseViewController {

    var mediaServerEndPoint: String?

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    /// 进入直播间
    func enterLiveRoom() {
        LiveManager.shared.enterLiveRoom()
    }

    /// 退出直播间
    func exitLiveRoom() {
        LiveManager.shared.exitLiveRoom()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(localVideoView)
        view.addSubview(closeBtn)

        view.addSubview(lookBtn)
        view.addSubview(liveBtn)
        view.addSubview(textInputBar)
        textInputBar.delegate = self

        enterLiveRoom()

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
        exitLiveRoom()
        let username = (LoginTools.sharedTools.userInfo().firstName ?? "[unknown first name]") + " " + (LoginTools.sharedTools.userInfo().lastName ?? "[unknown last name]")
        debugPrint("Live closed for user " + username)
        dismiss(animated: true)
    }
    
//    @IBAction func joinStorageSession(_: Any) {
//        print("button pressed")
//        joinStorageButton?.isHidden = true
//    }
    
    lazy var localVideoView: UIView = {
        // let localVideoView = UIView(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT() + 16, width: 200, height: 200))
        let localVideoView = UIView(frame: view.bounds) // 全屏展示(full screen display)
        return localVideoView
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 44, height: 44))
        closeBtn.backgroundColor = .clear
        closeBtn.setImage(UIImage(named: "nav_close_back"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeLive), for: .touchUpInside)
        return closeBtn
    }()

    lazy var lookBtn: UIButton = {
        let lookBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 66 - 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 66, height: 36))
        lookBtn.backgroundColor = UIColor.hexColorWithAlpha(color: "4E4744", alpha: 1)
        lookBtn.setImage(UIImage(named: "icon_eye"), for: .normal)
        if LoginTools.sharedTools.userInfo().isMaster ?? false {
            lookBtn.setTitle("0", for: .normal)
        } else {
            lookBtn.setTitle("22", for: .normal)
        }
        lookBtn.setTitleColor(.white, for: .normal)
        lookBtn.titleLabel?.font = UIFont.font(ofSize: 14, type: .Regular)
        lookBtn.addTarget(self, action: #selector(lookBtnClick), for: .touchUpInside)
        lookBtn.layer.cornerRadius = 5
        lookBtn.layer.masksToBounds = true
        return lookBtn
    }()

    @objc func lookBtnClick() {
        debugPrint("Look Button Clicked")
    }

    lazy var liveBtn: UIButton = {
        let liveBtn = UIButton(frame: CGRect(x: lookBtn.frame.minX - 50 - 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 50, height: 37))
        liveBtn.backgroundColor = .clear
        liveBtn.setImage(UIImage(named: "icon_onLive"), for: .normal)
        liveBtn.addTarget(self, action: #selector(liveBtnClick), for: .touchUpInside)
        return liveBtn
    }()

    @objc func liveBtnClick() {
        debugPrint("Live button clicked")
        debugPrint("Text Box is: " + textInput)
    }
    
    var textInput = ""
    var textTyping = false

    lazy var textInputBar: UITextField = {
        let textInputBar = UITextField(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 70, width: K_SCREEN_WIDTH - 40, height: 30))
        textInputBar.placeholder = "Gift / Comment"
        textInputBar.borderStyle = .roundedRect
        //textInputBar.textAlignment = .center
        
        return textInputBar
    }()
    
    var YOffset = CGFloat(300)
    var widthOffset = CGFloat(80)
    var heightOffset = CGFloat(40)
    
    func resizeTextUpward(_ textField : UITextField) {
        if textTyping == false {
            textField.frame = CGRectMake(textField.frame.minX + widthOffset, textField.frame.minY - YOffset, textField.frame.width - 2*widthOffset, textField.frame.height + heightOffset)
            textTyping = true
            view.addSubview(giftButton)
            view.addSubview(commentButton)
            
            view.addSubview(submitButton)
            if gift {
                textInputBar.placeholder = "Add a note to your gift"
                view.addSubview(firstPriceButton)
                view.addSubview(secondPriceButton)
                view.addSubview(thirdPriceButton)
            }
            else {
                textInputBar.placeholder = "Add a comment"
            }
        }
    }
    
    func resizeTextDownward(_ textField : UITextField) {
        if textTyping == true{
            textField.frame = CGRectMake(textField.frame.minX - widthOffset, textField.frame.minY + YOffset, textField.frame.width + 2*widthOffset, textField.frame.height - heightOffset)
            textTyping = false
            giftButton.removeFromSuperview()
            commentButton.removeFromSuperview()
            firstPriceButton.removeFromSuperview()
            secondPriceButton.removeFromSuperview()
            thirdPriceButton.removeFromSuperview()
            submitButton.removeFromSuperview()
            textInputBar.placeholder = "Gift / Comment"
        }
    }
    
    // buttons that will appear when text field has been opened
    
    var gift = true // !gift implies comment
    var giftValue = 3
    
    lazy var giftButton: UIButton = {
        let giftButton = UIButton(frame: CGRect(x: 10, y: K_SCREEN_HEIGHT - 70 - YOffset, width: 85, height: 32))
        giftButton.layer.borderColor = CGColor(red: 255/255, green: 1, blue: 1, alpha: 1)
        giftButton.layer.borderWidth = 0.5
        giftButton.backgroundColor = .clear
        giftButton.setTitle("Gift", for: .normal)
        giftButton.setTitleColor(.white, for: .normal)
        giftButton.layer.cornerRadius = 11
        giftButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 16)
        giftButton.addTarget(self, action: #selector(giftButtonClick), for: .touchUpInside)
        return giftButton
    }()
    
    @objc func giftButtonClick() {
        if !gift {
            giftButton.backgroundColor = .clear
            commentButton.backgroundColor = .clear
            gift = true
            textInputBar.placeholder = "Add a note to your gift"
            view.addSubview(firstPriceButton)
            view.addSubview(secondPriceButton)
            view.addSubview(thirdPriceButton)
            commentButton.layer.borderWidth = 0
            giftButton.layer.borderWidth = 0.5
        }
    }
    
    lazy var commentButton: UIButton = {
        let commentButton = UIButton(frame: CGRect(x: 10, y: K_SCREEN_HEIGHT - 70 - YOffset + 36, width: 85, height: 31))
        commentButton.backgroundColor = .clear
        commentButton.layer.borderColor = CGColor(red: 255/255, green: 1, blue: 1, alpha: 1)
        commentButton.setTitle("Comment", for: .normal)
        commentButton.setTitleColor(.white, for: .normal)
        commentButton.layer.cornerRadius = 10
        commentButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 16)
        commentButton.addTarget(self, action: #selector(commentButtonClick), for: .touchUpInside)
        return commentButton
    }()
    
    @objc func commentButtonClick() {
        if gift{
            gift = false
            commentButton.layer.borderWidth = 0.5
            giftButton.layer.borderWidth = 0
            textInputBar.placeholder = "Add a comment"
            firstPriceButton.removeFromSuperview()
            secondPriceButton.removeFromSuperview()
            thirdPriceButton.removeFromSuperview()
        }
    }
    
    lazy var firstPriceButton : UIButton = {
        let firstButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset, width: 34, height: 20))
        firstButton.backgroundColor = .clear
        firstButton.layer.borderColor = CGColor(red: 255/255, green: 1, blue: 1, alpha: 1)
        firstButton.layer.borderWidth = 0.5
        firstButton.setTitle("$3", for: .normal)
        firstButton.setTitleColor(.white, for: .normal)
        firstButton.layer.cornerRadius = 10
        firstButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 12)
        firstButton.addTarget(self, action: #selector(firstPriceButtonClick), for: .touchUpInside)
        return firstButton
    }()
    
    @objc func firstPriceButtonClick() {
        if giftValue != 3 {
            firstPriceButton.layer.borderWidth = 0.5
            secondPriceButton.layer.borderWidth = 0
            thirdPriceButton.layer.borderWidth = 0
            giftValue = 3
        }
    }
    
    lazy var secondPriceButton : UIButton = {
        let secondButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset + 25, width: 34, height: 20))
        secondButton.backgroundColor = .clear
        secondButton.layer.borderColor = CGColor(red: 255/255, green: 1, blue: 1, alpha: 1)
        secondButton.setTitle("$7", for: .normal)
        secondButton.setTitleColor(.white, for: .normal)
        secondButton.layer.cornerRadius = 10
        secondButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 12)
        secondButton.addTarget(self, action: #selector(secondPriceButtonClick), for: .touchUpInside)
        return secondButton
    }()
    
    @objc func secondPriceButtonClick() {
        if giftValue != 7 {
            firstPriceButton.layer.borderWidth = 0
            secondPriceButton.layer.borderWidth = 0.5
            thirdPriceButton.layer.borderWidth = 0
            giftValue = 7
        }
    }
    
    lazy var thirdPriceButton : UIButton = {
        let thirdButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset + 50, width: 34, height: 20))
        thirdButton.backgroundColor = .clear
        thirdButton.layer.borderColor = CGColor(red: 255/255, green: 1, blue: 1, alpha: 1)
        thirdButton.setTitle("$10", for: .normal)
        thirdButton.setTitleColor(.white, for: .normal)
        thirdButton.layer.cornerRadius = 10
        thirdButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 12)
        thirdButton.addTarget(self, action: #selector(thirdPriceButtonClick), for: .touchUpInside)
        return thirdButton
    }()
    
    @objc func thirdPriceButtonClick() {
        if giftValue != 10 {
            firstPriceButton.layer.borderWidth = 0
            secondPriceButton.layer.borderWidth = 0
            thirdPriceButton.layer.borderWidth = 0.5
            giftValue = 10
        }
    }
    
    lazy var submitButton : UIButton = {
        let submitButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 15 + 33 + 8, y: K_SCREEN_HEIGHT - 70 - YOffset + 12.5, width: 45, height: 45))
        submitButton.setImage(UIImage(named: "forward_arrow"), for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: #selector(submitButtonClick), for: .touchUpInside)
        return submitButton
    }()
    
    @objc func submitButtonClick(){
        textInput = textInputBar.text!
        textInputBar.text = ""
        resizeTextDownward(textInputBar)
        textInputBar.resignFirstResponder()
        debugPrint((gift ? "Gift" : "Comment") + " submitted")
        if gift {
            StreamingBackend.stream.logGift( gifterId: LoginTools.sharedTools.userInfo().id, value: giftValue, msg: textInput)
        }
    }
}

// text input delegate

extension LiveViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resizeTextDownward(textField)
        debugPrint("Text editing ended")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resizeTextUpward(textField)
        debugPrint("Text editing began")
    }
}

//preview stuff

struct LiveView: UIViewControllerRepresentable {
    typealias UIViewControllerType = LiveViewController
    func makeUIViewController(context: Context) -> LiveViewController {
            let vc = LiveViewController()
            return vc
        }
    func updateUIViewController(_ uiViewController: LiveViewController, context: Context) {
        }
    }

struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return LiveView()
    }
}
