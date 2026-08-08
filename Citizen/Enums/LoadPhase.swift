//
//  LoadPhase.swift
//  Citizen
//
//  Created by GE-Developer
//

enum LoadPhase: Hashable {
    case loading
    case needsAuth
    case ready
    case failed(outOfSpace: Bool)
}
