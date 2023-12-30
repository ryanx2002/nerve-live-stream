//
//  AppDelegate+Amplify.swift
//  NerveLive
//
//  Created by wbx on 2023/12/5.
//

import UIKit
import Amplify
import AmplifyPlugins
import AWSPluginsCore
import AWSS3
import AWSPinpoint

/// 添加Amplify
extension AppDelegate {
    func addAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
        } catch {
            print("An error occurred while setting up Amplify: \(error)")
        }
    }
}
