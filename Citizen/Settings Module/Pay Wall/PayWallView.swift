//
//  PayWallView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PayWallView: View {
    @EnvironmentObject private var store: StoreManager
    @Environment(LanguageManager.self) private var languageManager
    @StateObject private var vm: PayWallViewModel
    
    private var layoutDirection: LayoutDirection {
        Language.rtlLanguages.contains(languageManager.currentLanguageID)
        ? .rightToLeft
        : .leftToRight
    }
    
    init(_ store: StoreManager) {
        _vm = StateObject(wrappedValue: PayWallViewModel(store: store))
    }
    
    var body: some View {
        payWall
            .environmentObject(vm)
            .sheet(isPresented: $vm.showFeatures) {
                featuresSheet
                    .environment(\.layoutDirection, layoutDirection)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.citizen.background)
            }
            .alert(
                Text(vm.errorTitle),
                isPresented: $vm.showError,
                actions: { Button(vm.errorOK) {} },
                message: { Text(vm.errorDescription) }
            )
            .task { await vm.loadProducts() }
            .environment(\.layoutDirection, layoutDirection)
            .id(languageManager.currentLanguageID)
    }
}

// MARK: - Builder
extension PayWallView {
    private var payWall: some View {
        VStack(spacing: 0) {
            topper
            mainView
                .padding(.top, 5)
                .padding(.horizontal)
                .padding(.bottom, isFaceIDPhone ? 20 : 5)
        }
        .ignoresSafeArea()
        .background(background)
        .overlay(backButton)
    }
    
    private var mainView: some View {
        VStack(spacing: 0) {
            title
            subtitle
            featuresButton
            subscriptionButtons
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .opacity(vm.isLoading || vm.loadingError ? 0 : 1)
                .overlay { placeHolderLoader }
            
            VStack(spacing: 10) {
                restorePurchasesButton
                purchaseButton
                
                HStack(spacing: 6) {
                    bottomLink(text: vm.privacyPolicy) { vm.showPrivacyPolicy() }
                    bottomLink(text: vm.termsOfUse) { vm.showTermsOfUse() }
                }
            }
        }
    }
    
    private var featuresButton: some View {
        Button(action: vm.toggleFeaturesSheet) {
            HStack(spacing: 4) {
                Text(vm.featuresButtonTitle)
                Image.system.chevron
            }
            .font(.caption)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(Gradient.accent)
            .frame(height: 20)
        }
    }
    
    private var featuresSheet: some View {
        ZStack(alignment: .topTrailing) {
            Color.citizen.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(vm.featuresTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.mainText)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(vm.features, id: \.self) { feature in
                            HStack(alignment: .top, spacing: 10) {
                                Text(verbatim: "•")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Gradient.accent)
                                Text(feature)
                                    .foregroundStyle(Color.citizen.mainText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    Text(vm.subscriptionDisclaimer)
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .fontDesign(.rounded)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 30)
                .padding(.top, 60)
            }
            
            ExitButton()
                .padding()
        }
    }
    
    private var title: some View {
        Text(vm.title)
            .font(.title)
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .foregroundStyle(Color.citizen.mainText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(height: 34)
    }
    
    private var subtitle: some View {
        Text(vm.subtitle)
            .font(.subheadline)
            .fontDesign(.rounded)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.citizen.secondaryText)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .frame(height: 38)
    }
    
    private var restorePurchasesButton: some View {
        Button(action: vm.restorePurchases) {
            HStack {
                Image.system.restorePurchases
                    .font(.caption2)
                Text(vm.restorePurchasesTitle)
                    .font(.caption)
            }
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(height: 16)
        }
    }
    
    private var purchaseButton: some View {
        Button {
            vm.purchase(vm.chosenProduct)
        } label: {
            Text(vm.purchaseButtonTitle)
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Gradient.accent)
                .foregroundStyle(Color.citizen.white)
                .clipShape(Capsule())
                .shadow(color: Color.citizen.mainText, radius: 1)
        }
        .disabled(vm.purchaseButtonDisabled)
        .opacity(vm.purchaseButtonDisabled ? 0.3 : 1)
    }
    
    private var background: some View {
        Color.citizen.background
            .ignoresSafeArea()
    }
    
    private var backButton: some View {
        VStack {
            HStack {
                Spacer()
                ExitButton()
                    .padding()
            }
            Spacer()
        }
    }
    
    private var subscriptionButtons: some View {
        HStack(spacing: 12) {
            ForEach(vm.subscriptions) {
                ProductButton($0, isDisabled: vm.isWeeklyButtonDisabled($0))
            }
        }
    }
    
    private var topper: some View {
        ZStack(alignment: .bottom) {
            MatrixAnimationView(
                .georgian,
                color: Gradient.accent,
                updateDelay: nil,
                speedRange: 8...9
            )
            Rectangle()
                .frame(height: 40)
                .foregroundStyle(LinearGradient(
                    colors: [
                        .citizen.background,
                        .citizen.background.opacity(0.7),
                        Color.clear],
                    startPoint: .bottom,
                    endPoint: .top)
                )
        }
    }
    
    @ViewBuilder
    private var placeHolderLoader: some View {
        if vm.isLoading {
            ProgressView()
        } else if vm.loadingError {
            VStack {
                Image.system.warning
                    .font(.title2)
                Text(vm.errorTitle)
                    .font(.title3)
            }
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
        }
    }
    
    private func bottomLink(text: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .fontWeight(.light)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(1)
                .frame(maxWidth: .infinity)
                .frame(height: 31)
        }
    }
}
