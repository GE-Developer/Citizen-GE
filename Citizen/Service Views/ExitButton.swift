//
//  ExitButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExitButton: View {
    @Environment(\.dismiss) private var dismiss
    
    private let haptic = HapticsManager.shared
    
    var body: some View {
        exitButton
    }
}

// MARK: - Builder
extension ExitButton {
    private var exitButton: some View {
        Button(action: dismissPressed) {
            Image.system.xmark
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .padding(9)
                .background(background)
        }
    }
    
    private var background: some View {
        Circle()
            .foregroundStyle(.ultraThinMaterial)
            .shadow(color: Color.citizen.white.opacity(0.6), radius: 1)
    }
}

// MARK: - Logic
extension ExitButton {
    private func dismissPressed() {
        haptic.impact(style: .rigid)
        dismiss()
    }
}
