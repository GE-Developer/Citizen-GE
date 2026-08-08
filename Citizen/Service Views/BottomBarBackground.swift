//
//  BottomBarBackground.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct BottomBarBackground: View {
    var body: some View {
        VStack {
            Spacer()
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
            )
            .frame(height: isFaceIDPhone ? 100 : 116)
            .foregroundStyle(Color.citizen.groupBackground)
            .shadow(color: Color.citizen.navBarShadow, radius: 2)
        }
        .ignoresSafeArea()
    }
}
