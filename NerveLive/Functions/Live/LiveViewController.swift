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
import Amplify
import Collections

class LiveViewController: BaseViewController {

    var mediaServerEndPoint: String?
    
    var dareBubbles: Deque<UIView>?
    var comments: Deque<UILabel>?

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
    
    var giftSubscription : GraphQLSubscriptionOperation<Gift>?
    
    func createGiftSubscription(handler: @escaping (Gift) -> Any) {
        giftSubscription = Amplify.API.subscribe(request: .subscription(of: Gift.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("Gift subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdGift):
                    print("Successfully got gift from subscription: \(createdGift)")
                    DispatchQueue.main.async{
                        handler(createdGift)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
            }
        }
    }
    
    func cancelGiftSubscription() {
        giftSubscription?.cancel()
    }
    
    var commentSubscription : GraphQLSubscriptionOperation<Comment>?
    
    func createCommentSubscription(handler: @escaping (Comment) -> Any) {
        commentSubscription = Amplify.API.subscribe(request: .subscription(of: Comment.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("Comment subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdComment):
                    print("Successfully got comment from subscription: \(createdComment)")
                    DispatchQueue.main.async{
                        handler(createdComment)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
            }
        }
    }
    
    func cancelCommentSubscription() {
        commentSubscription?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dareBubbles = Deque<UIView>()
        comments = Deque<UILabel>()
        
        view.addSubview(localVideoView)
        view.addSubview(closeBtn)

        view.addSubview(lookBtn)
        view.addSubview(liveBtn)
        view.addSubview(textInputBar)
        textInputBar.delegate = self
        
        createGiftSubscription(handler: createDareBubble)
        createCommentSubscription(handler: createCommentLabel)
        
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
        cancelGiftSubscription()
        cancelCommentSubscription()
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
        //textInputBar.lineBreakMode = .byWordWrapping
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
            
            for comment in comments! {
                comment.frame = CGRectMake(20, comment.frame.minY - YOffset, K_SCREEN_WIDTH - 40, 15)
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
            for comment in comments! {
                comment.frame = CGRectMake(20, comment.frame.minY + YOffset, K_SCREEN_WIDTH - 40, 15)
            }
        }
    }
    
    // buttons that will appear when text field has been opened
    
    var gift = true // !gift implies comment
    var giftValue = 7
    
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
        secondButton.layer.borderWidth = 0.5
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
        thirdButton.setTitle("$15", for: .normal)
        thirdButton.setTitleColor(.white, for: .normal)
        thirdButton.layer.cornerRadius = 10
        thirdButton.titleLabel!.font = UIFont(name: "Inter-Regular",size: 12)
        thirdButton.addTarget(self, action: #selector(thirdPriceButtonClick), for: .touchUpInside)
        return thirdButton
    }()
    
    @objc func thirdPriceButtonClick() {
        if giftValue != 15 {
            firstPriceButton.layer.borderWidth = 0
            secondPriceButton.layer.borderWidth = 0
            thirdPriceButton.layer.borderWidth = 0.5
            giftValue = 15
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
        let user = LoginTools.sharedTools.userInfo()
        debugPrint((gift ? "Gift" : "Comment") + " submitted")
        if gift {
            StreamingBackend.stream.logGift( gifterId: user.id, value: giftValue, msg: textInput, gifterName: user.firstName!)
        }
        else {
            StreamingBackend.stream.logComment(name: user.firstName! + " " + user.lastName!, msg: textInput)
        }
    }
    
    // dare bubble factory
    
    func createDareBubble(gift: Gift){
        //94
        let msg = gift.gifterFullName! + ": " + gift.giftText!
        let value = gift.giftValue!
        var bubble = UIView(frame: CGRect(x: 200, y: K_SAFEAREA_TOP_HEIGHT() + 36 + 12, width: 173, height: 47))
        bubble.layer.cornerRadius = 20
        bubble.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        //bubble.layer.borderWidth = 0.5
        
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 1).cgColor,
        UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 0.3).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 192/K_SCREEN_WIDTH, b: 0, c: 0, d: 410/K_SCREEN_HEIGHT, tx: 87, ty: 23))
        layer0.bounds = bubble.bounds.insetBy(dx: -0.5*bubble.bounds.size.width, dy: -0.5*bubble.bounds.size.height)
        layer0.cornerRadius = 40
        bubble.layer.addSublayer(layer0)
        
        var msgLabel = UILabel(frame: CGRect(x: 10, y: 3, width: 114, height: 36))
        msgLabel.textColor = .white
        msgLabel.font = UIFont(name: "Inter-Bold", size: 11)
        msgLabel.lineBreakMode = .byWordWrapping
        msgLabel.numberOfLines = 0
        msgLabel.text = msg
        bubble.addSubview(msgLabel)
        
        var priceLabel = UILabel(frame: CGRect(x: 10 + 114 + 3, y: 0, width: 41, height: 46))
        priceLabel.textColor = UIColor(red: 0, green: 1, blue: 0.16, alpha: 1)
        priceLabel.font = UIFont(name: "Inter-Bold", size: 22)
        priceLabel.text = "$" + String(value)
        bubble.addSubview(priceLabel)
        
        updateDareBubbles(newBubble: bubble)
    }
    
    func updateDareBubbles(newBubble: UIView){
        let yShift = 47 + 12
        if dareBubbles?.count == 3 {
            dareBubbles?[0].removeFromSuperview()
            dareBubbles?.removeFirst()
            for element in dareBubbles! {
                element.frame = CGRect(x: 200, y: Int(element.frame.minY) - yShift, width: 173, height: 47)
            }
        }
        
        let newY = (dareBubbles?.count ?? 0) * yShift
        
        newBubble.frame = CGRect(x: 200, y: Int(K_SAFEAREA_TOP_HEIGHT()) + 36 + 12 + newY, width: 173, height: 47)
        
        
        dareBubbles?.append(newBubble)
        self.view.addSubview(newBubble)
    }
    
    //comment text factory
    func createCommentLabel(comment: Comment) {
        var commentLabel = UILabel(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 70 - 25, width: K_SCREEN_WIDTH - 40, height: 15))
        commentLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        commentLabel.font = UIFont(name: "Inter-Regular", size: 12)
        commentLabel.text = comment.commenterFullName! + ": " +  comment.commentText!
        updateComments(newComment: commentLabel)
    }
    
    func updateComments(newComment: UILabel){
        let yShift = 15 + 5
        if comments?.count == 3 {
            comments?[0].removeFromSuperview()
            comments?.removeFirst()
        }
        for element in comments! {
            element.frame = CGRect(x: 20, y: Int(element.frame.minY) - yShift, width: Int(K_SCREEN_WIDTH) - 40, height: 15)
        }
        comments?.append(newComment)
        self.view.addSubview(newComment)
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
