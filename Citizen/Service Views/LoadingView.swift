//
//  LoadingView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let title: String
    private let logoHeight: CGFloat = 100
    private let glowSize: CGFloat = 520
    private let trackWidth: CGFloat = 180
    private let trackHeight: CGFloat = 4
    private let indicatorWidth: CGFloat = 56
    private let duration: Double = 1.1
    
    private var glowOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.08
    }
    
    private var glowStops: [Gradient.Stop] {
        let accent = Color.citizen.accent
        return [
            .init(color: accent.opacity(glowOpacity), location: 0),
            .init(color: accent.opacity(glowOpacity * 0.72), location: 0.22),
            .init(color: accent.opacity(glowOpacity * 0.36), location: 0.45),
            .init(color: accent.opacity(glowOpacity * 0.13), location: 0.68),
            .init(color: accent.opacity(glowOpacity * 0.03), location: 0.85),
            .init(color: .clear, location: 1)
        ]
    }
    
    private var maxOffset: CGFloat {
        trackWidth - indicatorWidth
    }
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        loadingView
    }
}

// MARK: - Builder
extension LoadingView {
    private var loadingView: some View {
        ZStack {
            Color.citizen.background
            content
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnimatedLogo(withAnimation: false)
                .frame(height: logoHeight)
                .background(glow)
                .padding(.horizontal, 90)
            
            progressBar
                .padding(.top, 52)
            
            titleLabel
                .padding(.top, 22)
        }
    }
    
    private var glow: some View {
        RadialGradient(
            gradient: Gradient(stops: glowStops),
            center: .center,
            startRadius: 0,
            endRadius: glowSize / 2
        )
        .frame(width: glowSize, height: glowSize)
    }
    
    private var progressBar: some View {
        Capsule()
            .fill(Color.citizen.groupBackground)
            .frame(width: trackWidth, height: trackHeight)
            .overlay(alignment: .leading) { indicator }
    }
    
    @ViewBuilder
    private var indicator: some View {
        if reduceMotion {
            indicatorPill
                .offset(x: maxOffset / 2)
        } else {
            PhaseAnimator([false, true]) { isTrailing in
                indicatorPill
                    .offset(x: isTrailing ? maxOffset : 0)
            } animation: { _ in
                    .easeInOut(duration: duration)
            }
        }
    }
    
    private var indicatorPill: some View {
        Capsule()
            .fill(Gradient.accent)
            .frame(width: indicatorWidth)
            .shadow(color: Color.citizen.accent.opacity(0.6), radius: 6)
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
    }
}
