//
//  LiveManager+SignalClient.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import Foundation
import WebRTC

extension LiveManager: SignalClientDelegate {
    func signalClientDidConnect(_: SignalingClient) {
        signalingConnected = true
    }

    func signalClientDidDisconnect(_: SignalingClient) {
        signalingConnected = false
    }

    func setRemoteSenderClientId() {
        if self.remoteSenderClientId == nil {
            remoteSenderClientId = connectAsViewClientId
        }
    }
    
    func signalClient(_: SignalingClient, senderClientId: String, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp from [\(senderClientId)]")
        if !senderClientId.isEmpty {
            remoteSenderClientId = senderClientId
        }
        setRemoteSenderClientId()
        webRTCClient!.set(remoteSdp: sdp, clientId: senderClientId) { _ in
            print("Setting remote sdp and sending answer.")
            self.sendAnswer(recipientClientID: self.remoteSenderClientId!)
        }
    }

    func signalClient(_: SignalingClient, senderClientId: String, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate from [\(senderClientId)]")
        if !senderClientId.isEmpty {
            remoteSenderClientId = senderClientId
        }
        setRemoteSenderClientId()
        webRTCClient!.set(remoteCandidate: candidate, clientId: senderClientId)
    }
    
    func sendAnswer(recipientClientID: String) {
        if let webRTCClient = webRTCClient {
            webRTCClient.answer { localSdp in
                if let signalingClient = self.signalingClient {
                    signalingClient.sendAnswer(rtcSdp: localSdp, recipientClientId: recipientClientID)
                }
                print("Sent answer. Update peer connection map and handle pending ice candidates")
                webRTCClient.updatePeerConnectionAndHandleIceCandidates(clientId: recipientClientID)
            }
        }
    }
}
