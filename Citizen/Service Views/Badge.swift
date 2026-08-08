//
//  Badge.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct Badge: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        badge
    }
}

// MARK: - Builder
extension Badge {
    private var badge: some View {
        Text(text.uppercased())
            .font(.caption)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .lineLimit(1)
            .tracking(1)
            .foregroundStyle(Gradient.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Gradient.accent.opacity(0.18))
            }
    }
}
