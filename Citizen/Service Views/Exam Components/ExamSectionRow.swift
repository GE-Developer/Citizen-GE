//
//  ExamSectionRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamSectionRow: View {
    private let icon: Image
    private let title: String
    private let action: () -> Void
    
    init(icon: Image, title: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.action = action
    }
    
    var body: some View {
        row
    }
}

// MARK: - Builder
extension ExamSectionRow {
    private var row: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconPlace
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                
                Spacer(minLength: 8)
                
                Image.system.chevron
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private var iconPlace: some View {
        icon
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Gradient.accent)
            .frame(width: 24, height: 24)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Gradient.accent.opacity(0.15))
            }
    }
}
