//
//  ImageCompressApp.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 4/15/23.
//

import SwiftUI
import RevenueCat

@main
struct ImageCompressApp: App {
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(with: Configuration.builder(withAPIKey: REVENUECAT_API_KEY).build())
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: REVENUECAT_API_KEY).build()
        )
    }
    var body: some Scene {
        WindowGroup {
            LaunchView()
//                .task {
//                do {
//                    UserViewModel.shared.offerings = try await Purchases.shared.offerings()
//                } catch {
//                    print("Error Fetching Offerings: \(error)")
//                }
//            }
        }
    }
}

//        Purchases.configure(withAPIKey: REVENUECAT_API_KEY)
//        Purchases.shared.delegate = PurchasesDelegateHandler.shared
//        Purchases.shared.getProducts(["tier1", "teir2", "teir3"], completion:
//            { tipLevel in
//                print("HERE")
//                print(tipLevel)
//            })
