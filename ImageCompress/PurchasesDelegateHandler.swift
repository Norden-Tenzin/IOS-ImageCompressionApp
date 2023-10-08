//
//PurchasesDelegateHandler.swift
//ImageCompress
//
//Created by Tenzin Norden on 10 / 7 / 23.


import Foundation
import RevenueCat

class PurchasesDelegateHandler: NSObject, ObservableObject {
    static let shared = PurchasesDelegateHandler()
}

extension PurchasesDelegateHandler: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        UserViewModel.shared.customerInfo = customerInfo
    }
}
