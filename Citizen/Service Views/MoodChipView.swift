//
//  MoodChipView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MoodChipView: View {
    private let emoji: String
    private let title: String
    private let isSelected: Bool
    private let isExpanded: Bool
    
    init(_ mood: Mood, isSelected: Bool = false, isExpanded: Bool = false) {
        self.emoji = mood.emoji
        self.title = mood.title
        self.isSelected = isSelected
        self.isExpanded = isExpanded
    }
    
    var body: some View {
        moodChip
    }
}

// MARK: - Builder
extension MoodChipView {
    private var moodChip: some View {
        HStack(spacing: 5) {
            Text(emoji)
                .font(isExpanded ? .subheadline : .caption)
            
            Text(title)
                .font(isExpanded ? .subheadline : .caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(Gradient.accent)
        }
        .frame(maxWidth: isExpanded ? .infinity : nil)
        .padding(.horizontal, 8)
        .padding(.vertical, isExpanded ? 10 : 4)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Gradient.accent.opacity(isSelected ? 0.28 : 0.14))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    Gradient.accent.opacity(isSelected ? 0.65 : 0),
                    lineWidth: 1.5
                )
        }
        .scaleEffect(isSelected ? 1.04 : 1)
        .animation(.snappy(duration: 0.15, extraBounce: 0.15), value: isSelected)
    }
}
