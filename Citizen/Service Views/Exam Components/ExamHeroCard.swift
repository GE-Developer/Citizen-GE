//
//  ExamHeroCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamHeroCard: View {
    private let icon: Image
    private let title: String
    private let subtitle: String
    private let stats: [ExamHeroStat]
    private let buttonTitle: String
    private let action: () -> Void
    
    init(
        icon: Image,
        title: String,
        subtitle: String,
        stats: [ExamHeroStat],
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.stats = stats
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    var body: some View {
        card
    }
}

// MARK: - Builder
extension ExamHeroCard {
    private var card: some View {
        VStack(spacing: 16) {
            header
            ExamStatsStrip(stats: stats)
            startButton
        }
        .padding(16)
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
    
    private var header: some View {
        HStack(spacing: 14) {
            iconPlace
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .fontDesign(.rounded)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            
            Spacer(minLength: 0)
        }
    }
    
    private var iconPlace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Gradient.accent)
            
            icon
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.citizen.white)
        }
        .frame(width: 54, height: 54)
    }
    
    private var startButton: some View {
        Button(action: action) {
            Text(buttonTitle)
                .font(.headline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Gradient.accent)
                }
        }
    }
    
}
