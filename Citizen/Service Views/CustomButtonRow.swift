//
//  CustomButtonRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomButtonRow: View {
    private let icon: Image?
    private let circleImage: Image?
    private let title: String
    private let subtitle: String?
    private let additionalTitle: String?
    private let withCheckmark: Bool
    private let isCritical: Bool
    private let isLink: Bool
    
    private let action: () -> Void
    
    init(
        icon: Image? = nil,
        circleImage: Image? = nil,
        title: String,
        subtitle: String? = nil,
        additionalTitle: String? = nil,
        withCheckmark: Bool = false,
        isCritical: Bool = false,
        isLink: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.circleImage = circleImage
        self.title = title
        self.subtitle = subtitle
        self.additionalTitle = additionalTitle
        self.withCheckmark = withCheckmark
        self.isCritical = isCritical
        self.isLink = isLink
        self.action = action
    }
    
    var body: some View {
        customButtonRow
    }
}

// MARK: - Builder
extension CustomButtonRow {
    private var customButtonRow: some View {
        Button(action: action) {
            button
        }
        .disabled(withCheckmark)
    }
    
    private var button: some View {
        Group {
            HStack(spacing: 0) {
                iconPlace
                titlePlace
                Spacer()
                additionalPlace
                linkPlace
                checkmarkPlace
            }
            .padding(.vertical, subtitle == nil ? 16 : 6)
        }
    }
    
    private var iconPlace: some View {
        Group {
            if let icon {
                icon
                    .foregroundStyle(Gradient.accent)
                    .frame(width: 50)
            } else if let circleImage {
                circleImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.citizen.background, lineWidth: 1)
                    )
                    .shadow(color: Color.citizen.viewShadow, radius: 1)
                    .padding(.horizontal, 6)
                    .padding(6)
            } else {
                Spacer().frame(width: 20)
            }
        }
    }
    
    private var titlePlace: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .foregroundStyle(Color.citizen.mainText)
                .font(.headline)
                .fontWeight(isCritical ? .semibold : .regular)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        .fontDesign(.rounded)
        .opacity(withCheckmark ? 0.5 : 1)
        .multilineTextAlignment(.leading)
        .padding(.trailing)
    }
    
    private var additionalPlace: some View {
        Group {
            if let additionalTitle {
                Text(additionalTitle)
                    .foregroundStyle(Color.citizen.mainText)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .padding(.trailing)
            }
        }
    }
    
    private var linkPlace: some View {
        Group {
            if isLink {
                Image.system.chevron
                    .foregroundStyle(Color.citizen.blackAndWhite)
                    .font(.footnote)
                    .padding(.trailing)
            }
        }
    }
    
    private var checkmarkPlace: some View {
        Group {
            if withCheckmark {
                Image.system.checkmarkInCircle()
                    .foregroundStyle(Gradient.accent)
                    .font(.footnote)
                    .fontWeight(.heavy)
                    .padding(.trailing)
            }
        }
    }
}
