//
//  AppProtocols.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/25/23.
//

import Foundation
import StoreKit
import Amplify

// MARK: - StoreObserverDelegate

protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the restore operation was successful.
    func storeObserverRestoreDidSucceed()
    
    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
    
    //
    func successfulPurchase()
}
/*
protocol SubscriptionContainer : AnyObject {
    associatedtype T : Model
    
    var subscription : GraphQLSubscriptionOperation<T>? { get }
    func create(handler: @escaping (T) -> Any) -> GraphQLSubscriptionOperation<T>
    func cancel()
    
}*/
