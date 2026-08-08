//
//  PremiumLockModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PremiumLockModifier: ViewModifier {
    @EnvironmentObject private var store: StoreManager
    @Binding private var showPayWall: Bool
    
    private let swipable: Bool
    private let isIncluded: Bool
    
    init(_ showPayWall: Binding<Bool>, swipable: Bool, isIncluded: Bool) {
        self._showPayWall = showPayWall
        self.swipable = swipable
        self.isIncluded = isIncluded
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if isIncluded {
            content
                .opacity(store.isPremium ? 1 : 0.5)
                .disabled(!store.isPremium)
                .overlay {
                    if swipable {
                        swipableOverlay
                    } else {
                        notSwipableOverlay
                    }
                }
        } else {
            content
        }
    }
    
    @ViewBuilder
    private var swipableOverlay: some View {
        if !store.isPremium {
            Color.citizen.blackAndWhite.opacity(0.000001)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if value.translation.width > 50
                                && abs(value.translation.height) < 30 {
                                showPayWall = true
                            }
                        }
                )
                .onTapGesture {
                    showPayWall = true
                }
        }
    }
    
    @ViewBuilder
    private var notSwipableOverlay: some View {
        if !store.isPremium {
            Color.citizen.blackAndWhite.opacity(0.000001)
                .onTapGesture {
                    showPayWall = true
                }
        }
    }
}
