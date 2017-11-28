//
//  IAPHelper.swift
//  GPS Address Book
//
//  Created by surendra kumar on 7/5/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPHelperDelegate {
    func purchasedItem()
}

let INAPPPURCHASID = "InstsCamFullFeatureID"

class IAPHelper : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
   
    public static let sharedInstance = IAPHelper()
    
    var localProductID = [String]()
    var productArray  =  [SKProduct](){
        didSet{
            self.purchaseItem()
        }
    }
   
    var isTransactionInProgress = false
    var delegate : IAPHelperDelegate!
    
    // get only
    var isGoingOn : Bool{
        get {
            return isTransactionInProgress
        }
    }
    
    override init() {
        localProductID.append(INAPPPURCHASID)
        
    }
    
    func requestProductInfo(){
        if SKPaymentQueue.canMakePayments(){
            let productRequest = SKProductsRequest(productIdentifiers: NSSet(array: localProductID) as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
            print("Can perform Purchase")
        }else{
            print("Can nor perform purchase")
        }
    }
    
    private func purchaseItem(){
        //Only one item so hardcoded
        let payment = SKPayment(product: productArray[0])
        SKPaymentQueue.default().add(payment)
        // Observer
        SKPaymentQueue.default().add(self)
        self.isTransactionInProgress = true
    }
    
    func restorePurchseItem(){
        if SKPaymentQueue.canMakePayments(){
            SKPaymentQueue.default().restoreCompletedTransactions()
            //Observer 
            SKPaymentQueue.default().add(self)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products{
                self.productArray.append(product)
                 print("Product : \(product.productIdentifier): \(product.price)")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Observing..........")
        for transation in transactions {
            switch transation.transactionState {
            case .purchased,.restored:
                print("Success")
                SKPaymentQueue.default().finishTransaction(transation as SKPaymentTransaction)
                isTransactionInProgress = false
                // Call delegate
                delegate.purchasedItem()
                break
            case .failed:
                print("failed")
                SKPaymentQueue.default().finishTransaction(transation as SKPaymentTransaction)
                isTransactionInProgress = false
                break
            default:
                print("default")
                break
            }
        }
    }
    
    
}
