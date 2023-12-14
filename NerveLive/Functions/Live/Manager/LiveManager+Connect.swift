//
//  LiveManager+Connect.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import Foundation
import AWSMobileClient
import AWSKinesisVideo
import SVProgressHUD

/// 连接频道操作
extension LiveManager {
    
    /// 连接频道
    func connectChannel() {
        SVProgressHUD.show(withStatus: "Entering the live room")
        // Attempt to gather User Inputs
        guard let channelNameValue = channelName?.trim(), !channelNameValue.isEmpty else {
            popUpError(title: "Missing Required Fields", message: "Channel name is required for WebRTC connection")
            return
        }
        /*guard let awsRegionValue = regionName?.trim(), !awsRegionValue.isEmpty else {
            popUpError(title: "Missing Required Fields", message: "Region name is required for WebRTC connection")
            return
        }*/

        let awsRegionValue = regionName.trim()
        let awsRegionType = awsRegionValue.aws_regionTypeValue()
        if (awsRegionType == .Unknown) {
            popUpError(title: "Invalid Region Field", message: "Enter a valid AWS region name")
            return
        }
        // If ClientID is not provided generate one
        if (self.clientID.isEmpty) {
            self.localSenderId = NSUUID().uuidString.lowercased()
            print("Generated clientID is \(self.localSenderId)")
        }
        // Kinesis Video Client Configuration
        let configuration = AWSServiceConfiguration(region: awsRegionType, credentialsProvider: AWSMobileClient.default())
        AWSKinesisVideo.register(with: configuration!, forKey: awsKinesisVideoKey)

        // Attempt to retrieve signalling channel.  If it does not exist create the channel
        var channelARN = retrieveChannelARN(channelName: channelNameValue)
        if channelARN == nil {
            channelARN = createChannel(channelName: channelNameValue)
            if (channelARN == nil) {
                popUpError(title: "Unable to create channel", message: "Please validate all the input fields")
                return
            }
        }
        // check whether signalling channel will save its recording to a stream
        // only applies for master
        var usingMediaServer : Bool = false
        if self.isMaster {
            usingMediaServer = isUsingMediaServer(channelARN: channelARN!, channelName: channelNameValue)
            // Make sure that audio is enabled if ingesting webrtc connection
            if(usingMediaServer && !self.sendAudioEnabled) {
                popUpError(title: "Invalid Configuration", message: "Audio must be enabled to use MediaServer")
                return
            }
        }
        // get signalling channel endpoints
        let endpoints = getSignallingEndpoints(channelARN: channelARN!, region: awsRegionValue, isMaster: self.isMaster, useMediaServer: usingMediaServer)
        let wssURL = createSignedWSSUrl(channelARN: channelARN!, region: awsRegionValue, wssEndpoint: endpoints["WSS"]!, isMaster: self.isMaster)
        print("WSS URL :", wssURL?.absoluteString as Any)
        // get ice candidates using https endpoint
        let httpsEndpoint =
            AWSEndpoint(region: awsRegionType,
                        service: .KinesisVideo,
                        url: URL(string: endpoints["HTTPS"]!!))
        let RTCIceServersList = getIceCandidates(channelARN: channelARN!, endpoint: httpsEndpoint!, regionType: awsRegionType, clientId: localSenderId)
        webRTCClient = WebRTCClient(iceServers: RTCIceServersList, isAudioOn: sendAudioEnabled)
        webRTCClient!.delegate = self

        // Connect to signalling channel with wss endpoint
        print("Connecting to web socket from channel config")
        signalingClient = SignalingClient(serverUrl: wssURL!)
        signalingClient!.delegate = self
        signalingClient!.connect()

        // Create the video view
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            SVProgressHUD.dismiss()
            let vc = LiveViewController()
            vc.mediaServerEndPoint = endpoints["WEBRTC"] ?? nil
            vc.modalPresentationStyle = .fullScreen
            getAppWindow().rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func popUpError(title: String, message: String) {
        SVProgressHUD.dismiss()
        // debugPrint("Live: \(title)   \(message)")
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        getAppWindow().rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
