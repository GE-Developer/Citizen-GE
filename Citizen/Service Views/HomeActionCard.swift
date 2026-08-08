//
//  HomeActionCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HomeActionCard: View {
    private let icon: Image
    private let color: Color
    private let count: String
    private let title: String
    private let subtitle: String
    private let action: () -> Void
    
    init(
        icon: Image,
        color: Color,
        count: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.count = count
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    icon
                        .foregroundStyle(color)
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                    
                    Text(count)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.mainText)
                        .tracking(0.5)
                        .lineLimit(1)
                }
                Spacer()
                    .frame(height: 20)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .fontDesign(.rounded)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 3)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
