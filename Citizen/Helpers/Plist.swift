//
//  Plist.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct Plist {
    enum Key: String {
        case appID = "App ID"
        case weeklySubscription = "Weekly Subscription"
        case monthlySubscription = "Monthly Subscription"
        case developerLink = "Developer Link"
        case termsOfUse = "Terms of Use"
        case privacyPolicy = "Privacy Policy"
        case supabaseAnonKey = "Supabase Anon Key"
        case supabaseProjectUrl = "Supabase Project URL"
        case revenueCatAPIKey = "RevenueCat API Key"
        case revenueCatEntitlement = "RevenueCat Entitlement"
    }
    
    static private let plistName = "Property List"
    
    static private let values: [String: String] = {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return [:] }
        return dict.compactMapValues { $0 as? String }
    }()
    
    static func get(_ key: Key) -> String {
        values[key.rawValue] ?? ""
    }
}
