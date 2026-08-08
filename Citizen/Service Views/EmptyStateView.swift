//
//  EmptyStateView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct EmptyStateView: View {
    private let icon: Image
    private let title: String
    private let message: String
    
    init(icon: Image, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }
    
    var body: some View {
        emptyState
    }
}

// MARK: - Builder
extension EmptyStateView {
    private var emptyState: some View {
        VStack(spacing: 14) {
            icon
                .font(.system(size: 32))
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(width: 78, height: 78)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.citizen.groupBackground)
                }
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            
            Text(message)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
    }
}
