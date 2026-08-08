//
//  AppPurchase.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppPurchase: CaseIterable {
    case weekly
    case monthly
    
    var id: String {
        switch self {
        case .weekly:
            return Plist.get(.weeklySubscription)
        case .monthly:
            return Plist.get(.monthlySubscription)
        }
    }
    
    static var subscriptionIDs: [String] {
        [self.weekly.id, self.monthly.id]
    }
}
