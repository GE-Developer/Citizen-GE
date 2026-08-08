//
//  LinkButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct LinkButton: View {
    private let icon: Image
    private let title: String
    private let isAccent: Bool
    private let action: () -> Void
    
    init(
        icon: Image,
        title: String,
        isAccent: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.isAccent = isAccent
        self.action = action
    }
    
    var body: some View {
        linkButton
    }
}

// MARK: - Builder
extension LinkButton {
    private var linkButton: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                icon
                    .font(.headline)
                    .foregroundStyle(
                        isAccent
                        ? AnyShapeStyle(Gradient.accent)
                        : AnyShapeStyle(Color.citizen.secondaryText)
                    )
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background { background }
            .overlay { border }
        }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.citizen.groupBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Gradient.accent.opacity(isAccent ? 0.12 : 0))
            }
    }
    
    private var border: some View {
        RoundedRectangle(cornerRadius: 15)
            .strokeBorder(
                Gradient.accent.opacity(isAccent ? 0.45 : 0),
                lineWidth: 1
            )
    }
}
