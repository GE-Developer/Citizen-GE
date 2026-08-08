//
//  AuthActionButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthActionButton: View {
    private let title: String
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void
    private let height: CGFloat = 54
    
    init(title: String, isLoading: Bool, isDisabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Gradient.accent)
                if isLoading {
                    ProgressView()
                        .tint(Color.citizen.white)
                } else {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.white)
                }
            }
            .frame(height: height)
            .opacity(isDisabled ? 0.6 : 1)
        }
        .disabled(isDisabled)
    }
}
