//
//  FixedTextSizeModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct FixedTextSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(.large)
            .background {
                FixedTextSizeBridge()
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

// MARK: - Bridge
private struct FixedTextSizeBridge: UIViewRepresentable {
    func makeUIView(context: Context) -> FixedTextSizeBridgeView {
        FixedTextSizeBridgeView()
    }
    
    func updateUIView(_ uiView: FixedTextSizeBridgeView, context: Context) {
        uiView.lockTextTraits()
    }
}

// MARK: - Bridge View
private final class FixedTextSizeBridgeView: UIView {
    private weak var lockedWindow: UIWindow?
    private weak var lockedScene: UIWindowScene?
    
    private let sizeCategory: UIContentSizeCategory = .large
    private let legibilityWeight: UILegibilityWeight = .regular
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        lockTextTraits()
    }
    
    func lockTextTraits() {
        guard let window else { return }
        
        if window !== lockedWindow {
            lockedWindow = window
            apply(to: &window.traitOverrides)
        }
        
        guard let scene = window.windowScene, scene !== lockedScene else { return }
        
        lockedScene = scene
        apply(to: &scene.traitOverrides)
    }
    
    private func apply(to overrides: inout UITraitOverrides) {
        overrides.preferredContentSizeCategory = sizeCategory
        overrides.legibilityWeight = legibilityWeight
    }
}
