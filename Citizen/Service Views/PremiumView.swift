//
//  PremiumView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var rotation: Double = 0
    
    private let forPremiumText = "For Premium"
    private let premiumText = "Premium"
    private let basicText = "Basic"
    
    private let demonstration: Demonstration
    
    private var rotationAnimation: Animation {
        .easeInOut(duration: 0.6)
        .delay(1.5)
        .repeatForever(autoreverses: true)
    }
    
    enum Demonstration {
        case star
        case textAndStar
        case status
    }
    
    init(_ demonstration: Demonstration) {
        self.demonstration = demonstration
    }
    
    var body: some View {
        premiumView
    }
}

// MARK: - Builder
extension PremiumView {
    @ViewBuilder
    private var premiumView: some View {
        switch demonstration {
        case .star:
            starView
        case .textAndStar:
            starAndTextView
        case .status:
            statusView
        }
    }
    
    @ViewBuilder
    private var starView: some View {
        if !store.isPremium {
            Image.system.star
                .fontWeight(.bold)
                .foregroundStyle(Gradient.gold)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .font(.callout)
                .fontDesign(.rounded)
                .animation(rotationAnimation, value: rotation)
                .onAppear { startRotation() }
        }
    }
    
    @ViewBuilder
    private var starAndTextView: some View {
        if !store.isPremium {
            HStack {
                Text(forPremiumText)
                    .foregroundStyle(Gradient.gold)
                Image.system.star
                    .fontWeight(.bold)
                    .foregroundStyle(Gradient.gold)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .animation(rotationAnimation, value: rotation)
                    .offset(y: -3)
            }
            .font(.callout)
            .fontDesign(.rounded)
            .onAppear { startRotation() }
        }
    }
    
    private var statusView: some View {
        HStack {
            if store.isPremium {
                Image.system.star
                    .foregroundStyle(Color.citizen.secondaryGroupBackground)
            }
            
            Text(store.isPremium ? premiumText : basicText)
                .foregroundStyle(Color.citizen.secondaryGroupBackground)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .minimumScaleFactor(0.5)
        }
        .font(.caption2)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    store.isPremium
                    ? Gradient.gold
                    : Gradient.gray
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.citizen.secondaryGroupBackground, lineWidth: 2)
                )
        }
    }
}

// MARK: - Logic
extension PremiumView {
    private func startRotation() {
        guard rotation == 0 else { return }
        rotation = 360
    }
}
