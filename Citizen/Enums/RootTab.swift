//
//  RootTab.swift
//  Citizen
//
//  Created by GE-Developer
//

enum RootTab: Int, CaseIterable, Identifiable {
    case dictionary
    case home
    case settings
    
    var id: Int { rawValue }
}
