//
//  AppProtocols.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/25/23.
//

import Foundation
import StoreKit

// MARK: - StoreObserverDelegate

protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the restore operation was successful.
    func storeObserverRestoreDidSucceed()
    
    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
    
    //
    func successfulPurchase()
}
