//
//  AppDelegate+Live.swift
//  NerveLive
//
//  Created by wbx on 11/12/2023.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileClient

extension AppDelegate {
    
    func addLive() {
        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose

        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: cognitoIdentityUserPoolRegion, credentialsProvider: nil)

        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: cognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: cognitoIdentityUserPoolAppClientSecret,
                                                                        poolId: cognitoIdentityUserPoolId)

        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: awsCognitoUserPoolsSignInProviderKey)

        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")

                return
            }

            guard let userState = userState else {
                return
            }
            print("The user is \(userState.rawValue).")
            switch userState {
            case .signedIn:
                break
            default:
                DispatchQueue.main.async {

                }
            }
        }
    }
    
}
