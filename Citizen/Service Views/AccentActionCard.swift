//
//  AccentActionCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AccentActionCard: View {
    private let icon: Image
    private let avatar: CGImage?
    private let title: String
    private let subtitle: String?
    private let detail: String?
    private let action: () -> Void
    
    init(
        icon: Image,
        avatar: CGImage? = nil,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.avatar = avatar
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.action = action
    }
    
    var body: some View {
        card
    }
}

// MARK: - Builder
extension AccentActionCard {
    private var card: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconPlace
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.citizen.secondaryText)
                            .lineLimit(avatar == nil ? 2 : 1)
                    }
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Gradient.accent)
                    }
                }
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
                
                Image.system.chevron
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .padding()
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.groupBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Gradient.accent.opacity(0.12))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
            }
        }
    }
    
    private var iconPlace: some View {
        ZStack {
            if let avatar {
                Image.avatar(avatar)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Gradient.accent)
                icon
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.citizen.white)
            }
        }
        .frame(maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(avatar == nil ? AnyShape(RoundedRectangle(cornerRadius: 14)) : AnyShape(Circle()))
        .padding(avatar != nil ? 4 : 0)
        .overlay {
            if avatar != nil {
                Circle()
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 2)
            }
        }
        .padding(.vertical, 5)
    }
}
