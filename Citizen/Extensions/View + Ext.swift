//
//  View + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension View {
    var logo: some View {
        Image.other.svgLogo
            .resizable()
            .scaledToFit()
    }
    
    var isFaceIDPhone: Bool {
        DeviceLayout.hasHomeIndicator
    }
    
    var screenWidth: CGFloat {
        DeviceLayout.screenWidth
    }
    
    var screenHeight: CGFloat {
        DeviceLayout.screenHeight
    }
    
    var safeAreaTop: CGFloat {
        DeviceLayout.safeAreaTop
    }
    
    var safeAreaBottom: CGFloat {
        DeviceLayout.safeAreaBottom
    }
    
    func premiumOption(
        _ showPayWall: Binding<Bool>,
        swipable: Bool = false,
        isIncluded: Bool = true
    ) -> some View {
        modifier(
            PremiumLockModifier(showPayWall, swipable: swipable, isIncluded: isIncluded)
        )
    }
    
    @ViewBuilder
    func screenshotDisabled(_ isEnabled: Bool) -> some View {
        let securedText = "For Premium Only"
        
        ZStack {
            if isEnabled {
                VStack {
                    logo
                        .frame(height: 50)
                    Text(securedText)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.citizen.mainText)
                }
            }
            self.mask {
                if isEnabled {
                    ScreenShotPreventerMask()
                        .ignoresSafeArea()
                } else {
                    Color.white
                        .ignoresSafeArea()
                }
            }
            .animation(nil, value: isEnabled)
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    func shimmering() -> some View {
        modifier(Shimmer())
    }
    
    func voiceHighlight(isActive: Bool) -> some View {
        modifier(VoiceHighlight(isActive: isActive))
    }
    
    func voiceUnavailableNotice() -> some View {
        modifier(VoiceNoticeModifier())
    }
    
    func feedbackToast() -> some View {
        modifier(FeedbackToastModifier())
    }
    
    func fixedTextSize() -> some View {
        modifier(FixedTextSizeModifier())
    }
}
