//
//  QuizCTAButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuizCTAButton: View {
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void
    
    init(title: String, isEnabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        ctaButton
    }
}

// MARK: - Builder
extension QuizCTAButton {
    private var ctaButton: some View {
        Button(action: action) {
            Text(title)
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
                        if isEnabled {
                            Gradient.accent.opacity(0.7)
                        }
                    }
                }
                .foregroundStyle(Color.citizen.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(.bottom, isFaceIDPhone ? -5 : 16)
        .disabled(!isEnabled)
        .transaction {
            $0.disablesAnimations = true
            $0.animation = nil
        }
        .background {
            Color.citizen.groupBackground
                .ignoresSafeArea()
        }
    }
}
