//
//  CheckmarkView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CheckmarkView: View {
    private let isFilled: Bool
    
    init(_ isFilled: Bool = true) {
        self.isFilled = isFilled
    }
    
    var body: some View {
        Image.system.checkmarkInCircle(isFilled)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 18)
            .foregroundStyle(
                isFilled
                ? Gradient.accent
                : LinearGradient(
                    colors: [Color.citizen.secondaryText],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .fontWeight(.light)
    }
}
