//
//  CitizenApp.swift
//  Citizen
//
//  Created by GE-Developer on 13.11.25.
//

import SwiftUI
import RevenueCat

@main
struct CitizenApp: App {
    init() {
        Purchases.configure(withAPIKey: Plist.get(.revenueCatAPIKey))
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
