//
//  VoiceNoticeModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct VoiceNoticeModifier: ViewModifier {
    private let manager = VoiceActingManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let text = manager.unavailableNotice {
                    notice(text)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: manager.unavailableNotice)
    }
    
    private func notice(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image.system.voiceUnavailable
                .font(.subheadline)
                .foregroundStyle(Color.citizen.secondaryText)
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(Color.citizen.groupBackground)
        }
        .padding(.horizontal, 24)
    }
}
