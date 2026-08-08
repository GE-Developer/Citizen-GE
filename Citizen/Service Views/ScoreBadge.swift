//
//  ScoreBadge.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ScoreBadge: View {
    private let value: String
    private let title: String
    
    init(value: String, title: String) {
        self.value = value
        self.title = title
    }
    
    var body: some View {
        badge
    }
}

// MARK: - Builder
extension ScoreBadge {
    private var badge: some View {
        HStack(spacing: 8) {
            icon
            valueLabel
            titleLabel
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(capsuleBackground)
        .overlay(capsuleBorder)
    }
    
    private var icon: some View {
        Image.system.bolt
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(Gradient.accent)
    }
    
    private var valueLabel: some View {
        Text(value)
            .font(.footnote)
            .fontWeight(.heavy)
            .foregroundStyle(Color.citizen.mainText)
    }
    
    private var titleLabel: some View {
        Text(title.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .tracking(1.5)
            .foregroundStyle(Gradient.accent.opacity(0.75))
    }
    
    private var capsuleBackground: some View {
        Capsule()
            .fill(Gradient.accent.opacity(0.14))
            .shadow(color: Color.citizen.accent.opacity(0.35), radius: 10)
    }
    
    private var capsuleBorder: some View {
        Capsule()
            .strokeBorder(Gradient.accent.opacity(0.55), lineWidth: 1)
    }
}
