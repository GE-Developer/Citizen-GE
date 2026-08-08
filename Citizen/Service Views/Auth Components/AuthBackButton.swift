//
//  AuthBackButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthBackButton: View {
    private let isDisabled: Bool
    private let action: () -> Void
    
    private let side: CGFloat = 40
    private let haptics = HapticsManager.shared
    
    init(isDisabled: Bool, action: @escaping () -> Void) {
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: back) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.citizen.groupBackground)
                .frame(width: side, height: side)
                .overlay {
                    Image.system.back
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.mainText)
                }
        }
        .disabled(isDisabled)
    }
    
    private func back() {
        haptics.impact()
        action()
    }
}
