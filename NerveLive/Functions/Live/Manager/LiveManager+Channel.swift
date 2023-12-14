//
//  LiveManager+Channel.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import Foundation
import AWSKinesisVideo
import AWSMobileClient
import WebRTC
import AWSKinesisVideoSignaling

/// 频道操作
extension LiveManager {
    // create a signalling channel with the provided channelName.
    // Return the ARN of created channel on success, nil on failure
    func createChannel(channelName: String) -> String? {
        var channelARN : String?
        /*
            equivalent AWS CLI command:
            aws kinesisvideo create-signaling-channel --channel-name channelName --region cognitoIdentityUserPoolRegion
        */
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        let createSigalingChannelInput = AWSKinesisVideoCreateSignalingChannelInput.init()
        createSigalingChannelInput?.channelName = channelName
        kvsClient.createSignalingChannel(createSigalingChannelInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error creating channel \(error)")
            } else {
                print("Channel ARN : ", task.result?.channelARN ?? "")
                channelARN = task.result?.channelARN
            }
        }).waitUntilFinished()
        return channelARN
    }

    // attempt to retrieve channelARN with provided channelName.
    // Returns channelARN if channel exists otherwise returns nil
    // Note: if this function returns nil check whether it failed because channel doesn not exist or because the credentials are invalid
    func retrieveChannelARN(channelName: String) -> String? {
        var channelARN : String?
        /*
            equivalent AWS CLI command:
            aws kinesisvideo describe-signaling-channel --channelName channelName --region cognitoIdentityUserPoolRegion
        */
        let describeInput = AWSKinesisVideoDescribeSignalingChannelInput()
        describeInput?.channelName = channelName
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        kvsClient.describeSignalingChannel(describeInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error describing channel: \(error)")
            } else {
                print("Channel ARN : ", task.result!.channelInfo!.channelARN ?? "Channel ARN empty.")
                channelARN = task.result?.channelInfo?.channelARN
            }
        }).waitUntilFinished()
        return channelARN
    }
    
    // check media server is enabled for signalling channel
    func isUsingMediaServer(channelARN: String, channelName: String) -> Bool {
        var usingMediaServer : Bool = false
        /*
            equivalent AWS CLI command:
            aws kinesisvideo describe-media-storage-configuration --channel-name channelARN --region cognitoIdentityUserPoolRegion
        */
        let mediaStorageInput = AWSKinesisVideoDescribeMediaStorageConfigurationInput()
        mediaStorageInput?.channelARN = channelARN
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        kvsClient.describeMediaStorageConfiguration(mediaStorageInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error retriving Media Storage Configuration: \(error)")
            } else {
                usingMediaServer = task.result?.mediaStorageConfiguration!.status == AWSKinesisVideoMediaStorageConfigurationStatus.enabled
                // the app doesn't use the streamARN but could be useful information for the user
                if (usingMediaServer) {
                    print("Stream ARN : ", task.result?.mediaStorageConfiguration!.streamARN ?? "No Stream ARN.")
                }
            }
        }).waitUntilFinished()
        return usingMediaServer
    }
    
    // Get signalling endpoints for the given signalling channel ARN
    func getSignallingEndpoints(channelARN: String, region: String, isMaster: Bool, useMediaServer: Bool) -> Dictionary<String, String?> {
        
        var endpoints = Dictionary <String, String?>()
        /*
            equivalent AWS CLI command:
            aws kinesisvideo get-signaling-channel-endpoint --channel-arn channelARN --single-master-channel-endpoint-configuration Protocols=WSS,HTTPS[,WEBRTC],Role=MASTER|VIEWER --region cognitoIdentityUserPoolRegion
            Note: only include WEBRTC in Protocols if you need a media-server endpoint
        */
        let singleMasterChannelEndpointConfiguration = AWSKinesisVideoSingleMasterChannelEndpointConfiguration()
        singleMasterChannelEndpointConfiguration?.protocols = videoProtocols
        singleMasterChannelEndpointConfiguration?.role = getSingleMasterChannelEndpointRole(isMaster: isMaster)
        
        if(useMediaServer){
            singleMasterChannelEndpointConfiguration?.protocols?.append("WEBRTC")
        }
 
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)

        let signalingEndpointInput = AWSKinesisVideoGetSignalingChannelEndpointInput()
        signalingEndpointInput?.channelARN = channelARN
        signalingEndpointInput?.singleMasterChannelEndpointConfiguration = singleMasterChannelEndpointConfiguration

        kvsClient.getSignalingChannelEndpoint(signalingEndpointInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
               print("Error to get channel endpoint: \(error)")
            } else {
                print("Resource Endpoint List : ", task.result!.resourceEndpointList!)
            }
            //TODO: Test this popup
            guard (task.result?.resourceEndpointList) != nil else {
                self.popUpError(title: "Invalid Region Field", message: "No endpoints found")
                return
            }
            for endpoint in task.result!.resourceEndpointList! {
                switch endpoint.protocols {
                case .https:
                    endpoints["HTTPS"] = endpoint.resourceEndpoint
                case .wss:
                    endpoints["WSS"] = endpoint.resourceEndpoint
                case .webrtc:
                    endpoints["WEBRTC"] = endpoint.resourceEndpoint
                case .unknown:
                    print("Error: Unknown endpoint protocol ", endpoint.protocols, "for endpoint" + endpoint.description())
                @unknown default:
                    break
                }
            }
        }).waitUntilFinished()
        return endpoints
    }
    
    // get appropriate AWSKinesisVideoChannelRole
    func getSingleMasterChannelEndpointRole(isMaster: Bool) -> AWSKinesisVideoChannelRole {
        if isMaster {
            return .master
        }
        return .viewer
    }
    
    func createSignedWSSUrl(channelARN: String, region: String, wssEndpoint: String?, isMaster: Bool) -> URL? {
        // get AWS credentials to sign WSS Url with
        var AWSCredentials : AWSCredentials?
        AWSMobileClient.default().getAWSCredentials { credentials, _ in
            AWSCredentials = credentials
        }
        
        while(AWSCredentials == nil){
            usleep(5)
        }

        var httpURlString = wssEndpoint!
            + "?X-Amz-ChannelARN=" + channelARN
        if !isMaster {
            httpURlString += "&X-Amz-ClientId=" + self.localSenderId
        }
        let httpRequestURL = URL(string: httpURlString)
        let wssRequestURL = URL(string: wssEndpoint!)
        let wssURL = KVSSigner
            .sign(signRequest: httpRequestURL!,
                  secretKey: (AWSCredentials?.secretKey)!,
                  accessKey: (AWSCredentials?.accessKey)!,
                  sessionToken: (AWSCredentials?.sessionKey)!,
                  wssRequest: wssRequestURL!,
                  region: region)
        return wssURL
    }
    
    // Get list of Ice Server Config
    func getIceCandidates(channelARN: String, endpoint: AWSEndpoint, regionType: AWSRegionType, clientId: String) -> [RTCIceServer] {
        var RTCIceServersList = [RTCIceServer]()
        // TODO: don't use the self.regionName.text!
        let kvsStunUrlStrings = ["stun:stun.kinesisvideo." + self.regionName + ".amazonaws.com:443"]
        /*
            equivalent AWS CLI command:
            aws kinesis-video-signaling get-ice-server-config --channel-arn channelARN --client-id clientId --region cognitoIdentityUserPoolRegion
        */
        let configuration =
            AWSServiceConfiguration(region: regionType,
                                    endpoint: endpoint,
                                    credentialsProvider: AWSMobileClient.default())
        AWSKinesisVideoSignaling.register(with: configuration!, forKey: awsKinesisVideoKey)
        let kvsSignalingClient = AWSKinesisVideoSignaling(forKey: awsKinesisVideoKey)

        let iceServerConfigRequest = AWSKinesisVideoSignalingGetIceServerConfigRequest.init()

        iceServerConfigRequest?.channelARN = channelARN
        iceServerConfigRequest?.clientId = clientId
        kvsSignalingClient.getIceServerConfig(iceServerConfigRequest!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error to get ice server config: \(error)")
            } else {
                print("ICE Server List : ", task.result!.iceServerList!)

                for iceServers in task.result!.iceServerList! {
                    RTCIceServersList.append(RTCIceServer.init(urlStrings: iceServers.uris!, username: iceServers.username, credential: iceServers.password))
                }

                RTCIceServersList.append(RTCIceServer.init(urlStrings: kvsStunUrlStrings))
            }
        }).waitUntilFinished()
        return RTCIceServersList
    }
}
