//
//  NavigationToolButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct NavigationToolButton: View {
    private let image: Image
    private let action: () -> Void
    
    init(_ image: Image, action: @escaping () -> Void) {
        self.image = image
        self.action = action
    }
    
    var body: some View {
        settingsButton
    }
}

// MARK: - Builder
extension NavigationToolButton {
    private var settingsButton: some View {
        Button(action: action) {
            image
                .foregroundStyle(Gradient.accent)
                .font(.title2)
                .frame(width: 40, height: 50)
        }
    }
}
