//
//  ExamSessionBottomBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamSessionBottomBar: View {
    private let ctaTitle: String
    private let canGoBack: Bool
    private let canGoForward: Bool
    private let onBack: () -> Void
    private let onForward: () -> Void
    private let onCTA: () -> Void
    
    init(
        ctaTitle: String,
        canGoBack: Bool,
        canGoForward: Bool,
        onBack: @escaping () -> Void,
        onForward: @escaping () -> Void,
        onCTA: @escaping () -> Void
    ) {
        self.ctaTitle = ctaTitle
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.onBack = onBack
        self.onForward = onForward
        self.onCTA = onCTA
    }
    
    var body: some View {
        bar
    }
}

// MARK: - Builder
extension ExamSessionBottomBar {
    private var bar: some View {
        HStack(spacing: 10) {
            navButton(Image.system.back, enabled: canGoBack, action: onBack)
            ctaButton
            navButton(Image.system.chevron, enabled: canGoForward, action: onForward)
        }
        .padding(.horizontal)
        .padding(.bottom, isFaceIDPhone ? -5 : 16)
        .transaction {
            $0.disablesAnimations = true
            $0.animation = nil
        }
        .background {
            Color.citizen.groupBackground
                .ignoresSafeArea()
        }
    }
    
    private var ctaButton: some View {
        Button(action: onCTA) {
            Text(ctaTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background {
                    ZStack {
                        Color.citizen.background
                        Gradient.accent.opacity(0.7)
                    }
                }
                .foregroundStyle(Color.citizen.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func navButton(
        _ icon: Image,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            icon
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    enabled
                    ? Color.citizen.mainText
                    : Color.citizen.secondaryText.opacity(0.4)
                )
                .frame(width: 56, height: 60)
                .background(Color.citizen.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!enabled)
    }
}
