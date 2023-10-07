//
//  ImageCompressApp.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 4/15/23.
//

import SwiftUI
//import RevenueCat

@main
struct ImageCompressApp: App {
//    init() {
//        Purchases.logLevel = .debug
//        Purchases.configure(withAPIKey: REVENUECAT_API_KEY)
//        Purchases.shared.getProducts(["tier1", "teir2", "teir3", "teir4"], completion:
//            { tipLevel in
//                print("HERE")
//                print(tipLevel)
//            })
//    }
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
