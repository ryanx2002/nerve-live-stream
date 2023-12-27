//
//  StoreObserver.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/25/23.
//

import Foundation
import StoreKit

class StoreObserver: NSObject {
    
    
    //Initialize the store observer.
    override init() {
        super.init()
        //Other initialization here.
    }

    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    var purchased = [SKPaymentTransaction]()
    
    var restored = [SKPaymentTransaction]()

    fileprivate var hasRestorablePurchases = false
    
    weak var delegate: StoreObserverDelegate?
    
    // MARK: - Submit Payment Request
    
    /// Create and add a payment request to the payment queue.
    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Restore All Restorable Purchases
    
    /// Restores all previously completed purchases.
    func restore() {
        if !restored.isEmpty {
            restored.removeAll()
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Handle Payment Transactions
    
    /// Handles successful purchase transactions.
    fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        print("Deliver content for \(transaction.payment.productIdentifier).")
        self.delegate?.successfulPurchase()
        
        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "Purchase of \(transaction.payment.productIdentifier) has failed"
        
        if let error = transaction.error {
            message += "\nError: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        }
        
        // Don’t send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(message)
            }
        }
        else {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage("Transaction cancelled")
            }
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
        hasRestorablePurchases = true
        restored.append(transaction)
        print("Restored purchase of \(transaction.payment.productIdentifier).")
        
        DispatchQueue.main.async {
            self.delegate?.storeObserverRestoreDidSucceed()
        }
        // Finishes the restored transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

extension StoreObserver : SKPaymentTransactionObserver {
    /// The system calls this when there are transactions in the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            // Don’t block the UI. Allow the user to continue using the app.
            case .deferred: print("Allow the user to continue using your app.")
            // The purchase was successful.
            case .purchased: handlePurchased(transaction)
            // The transaction failed.
            case .failed: handleFailed(transaction)
            // There are restored products.
            case .restored: handleRestored(transaction)
            @unknown default: fatalError("Unknown payment transaction case.")
            }
        }
    }
    
    /// Logs all transactions that the system has removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("\(transaction.payment.productIdentifier) has been removed.")
        }
    }
    
    /// The system calls this when an error occurs while restoring purchases. Notify the user about the error.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(error.localizedDescription)
            }
        }
    }
    
    /// The system calls this when the payment queue has processed all restorable transactions.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("The payment queue has processed all restorable transactions.")
        
        if !hasRestorablePurchases {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage("There are no restorable purchases.")
            }
        }
    }
}
