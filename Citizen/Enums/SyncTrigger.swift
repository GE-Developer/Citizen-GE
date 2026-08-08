//
//  SyncTrigger.swift
//  Citizen
//
//  Created by GE-Developer
//

enum SyncTrigger: String {
    case launch
    case signIn
    case networkRestored
    case foreground
    case background
    case debounce
    case retry
    case coalesced
}
