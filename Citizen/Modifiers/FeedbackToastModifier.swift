//
//  FeedbackToastModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct FeedbackToastModifier: ViewModifier {
    private let manager = FeedbackManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message = manager.message {
                    toast(message)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: manager.message)
    }
    
    private func toast(_ message: ToastMessage) -> some View {
        HStack(spacing: 8) {
            icon(for: message.style)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color(for: message.style))
            Text(message.text)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.citizen.groupBackground)
        }
        .padding(.horizontal, 24)
    }
    
    private func icon(for style: ToastStyle) -> Image {
        switch style {
        case .success: return .system.checkmark
        case .info:    return .system.sync
        case .error:   return .system.warning
        }
    }
    
    private func color(for style: ToastStyle) -> Color {
        switch style {
        case .success: return Color.citizen.greenDark
        case .info:    return Color.citizen.accent
        case .error:   return Color.citizen.redDark
        }
    }
}
