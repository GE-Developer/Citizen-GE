//
//  TabBarState.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class TabBarState {
    var selectedTab: RootTab = .home
    
    var isVisible: Bool {
        depth(for: selectedTab) == 0
    }
    
    private var depths: [RootTab: Int] = [:]
    
    let height: CGFloat = 65
    
    func enterStack(for tab: RootTab) {
        depths[tab, default: 0] += 1
    }
    
    func exitStack(for tab: RootTab) {
        depths[tab] = max(0, depth(for: tab) - 1)
    }
    
    private func depth(for tab: RootTab) -> Int {
        depths[tab, default: 0]
    }
}
