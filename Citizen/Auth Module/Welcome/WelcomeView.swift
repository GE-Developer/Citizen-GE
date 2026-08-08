//
//  WelcomeView.swift
//  Citizen
//
//  Created by GE-Developer
//

import AuthenticationServices
import SwiftUI

struct WelcomeView: View {
    @Binding private var route: AuthRoute
    
    @Environment(\.openURL) private var openURL
    
    @State private var vm = WelcomeViewModel()
    
    init(route: Binding<AuthRoute>) {
        self._route = route
    }
    
    var body: some View {
        welcomeView
            .task { vm.noticeBanIfNeeded() }
            .sheet(isPresented: $vm.isShowingLanguageSheet) { languageSheet }
    }
}

// MARK: - Builder
extension WelcomeView {
    private var welcomeView: some View {
        AuthScreen {
            languageButton
                .frame(maxWidth: .infinity, alignment: .trailing)
        } content: {
            VStack(spacing: 20) {
                AnimatedLogo()
                    .padding(.horizontal, 85)
                welcomeTitle
                featuresCarousel
            }
        } bottomBar: {
            VStack(spacing: 6) {
                signInButton
                orDivider
                appleButton
                switchModeButton
                legalText
            }
        }
    }
    
    private var languageButton: some View {
        Button(action: vm.showLanguageSheet) {
            HStack(spacing: 6) {
                Image.system.language
                Text(vm.currentLanguageName)
                    .fontWeight(.medium)
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background {
                Capsule()
                    .fill(Color.citizen.groupBackground)
            }
        }
        .disabled(vm.isLoading)
    }
    
    private var welcomeTitle: some View {
        Text(vm.subtitle)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
    }
    
    private var featuresCarousel: some View {
        VStack(spacing: 14) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(vm.features) { feature in
                        featureCard(feature)
                            .frame(width: screenWidth * 0.6)
                            .id(feature.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $vm.selectedFeature, anchor: .leading)
            .scrollIndicators(.hidden)
            
            HStack(spacing: 6) {
                ForEach(vm.features) { feature in
                    let isSelected = vm.selectedFeature == feature.id
                    Capsule()
                        .fill(
                            isSelected
                            ? Color.citizen.accent
                            : Color.citizen.secondaryText.opacity(0.3)
                        )
                        .frame(width: isSelected ? 20 : 6, height: 6)
                }
            }
            .animation(.easeOut, value: vm.selectedFeature)
        }
    }
    
    @ViewBuilder
    private func featureCard(_ feature: AuthFeature) -> some View {
        let isSelected = vm.selectedFeature == feature.id
        
        let icon: Image = switch feature.id {
        case 1: .system.practice
        case 2: .system.bolt
        case 3: .system.timer
        case 4: .system.voiceActing
        case 5: .system.hint
        case 6: .system.dictionary
        default: .system.leaderboard
        }
        
        VStack(alignment: .leading, spacing: 0) {
            icon
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Gradient.accent)
                .lineLimit(2)
            
            Spacer(minLength: 12)
            
            Text(feature.value)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(
                    isSelected
                    ? AnyShapeStyle(Gradient.accent)
                    : AnyShapeStyle(Color.citizen.mainText)
                )
                .padding(.bottom, 2)
                .lineLimit(2)
            
            Text(feature.label)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color.citizen.mainText)
                .padding(.bottom, 9)
                .lineLimit(2)
            
            Text(feature.caption)
                .font(.caption)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(2, reservesSpace: true)
        }
        .fontDesign(.rounded)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.7)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 200)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.citizen.groupBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Gradient.accent.opacity(isSelected ? 0.12 : 0))
                }
                .overlay {
                    if isSelected {
                        PremiumSparkleView()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .transition(.opacity)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Gradient.accent.opacity(isSelected ? 0.45 : 0),
                            lineWidth: 1
                        )
                }
        }
        .animation(.easeOut, value: isSelected)
    }
    
    private var signInButton: some View {
        AuthActionButton(
            title: vm.signInTitle,
            isLoading: false,
            isDisabled: vm.isLoading,
            action: signInPressed
        )
    }
    
    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.citizen.secondaryText)
                .opacity(0.25)
                .frame(height: 1)
            Text(vm.orTitle)
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
            Rectangle()
                .fill(Color.citizen.secondaryText)
                .opacity(0.25)
                .frame(height: 1)
        }
    }
    
    private var appleButton: some View {
        AppleAuthButton(
            title: vm.appleTitle,
            scopes: [.fullName, .email],
            onNonce: vm.startAppleSignIn,
            onCompletion: handleAppleCompletion
        )
        .disabled(vm.isLoading)
    }
    
    private var switchModeButton: some View {
        Button(action: switchModePressed) {
            HStack(spacing: 4) {
                Text(vm.switchPrompt)
                    .foregroundStyle(Color.citizen.secondaryText)
                Text(vm.switchAction)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.accent)
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
        }
        .disabled(vm.isLoading)
    }
    
    private var legalText: some View {
        Text(vm.legalText)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .tint(Color.citizen.accent)
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction(handler: openLegalLink))
    }
    
    private var languageSheet: some View {
        VStack(spacing: 0) {
            CustomForm(headerText: vm.languageSheetTitle) {
                let languages = Array(Language.allCases.enumerated())
                
                ForEach(languages, id: \.element.id) { index, language in
                    VStack(spacing: 0) {
                        CustomButtonRow(
                            title: language.localizedName,
                            subtitle: language.englishName,
                            withCheckmark: vm.isCurrentLanguage(language),
                            action: { vm.setLanguage(language) }
                        )
                        if index < Language.allCases.count - 1 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.citizen.background)
    }
}

// MARK: - Logic
extension WelcomeView {
    private func signInPressed() {
        vm.tapFeedback()
        route = .signIn
    }
    
    private func switchModePressed() {
        vm.tapFeedback()
        route = .signUp
    }
    
    private func openLegalLink(_ link: URL) -> OpenURLAction.Result {
        guard let url = vm.legalURL(for: link) else { return .discarded }
        openURL(url)
        return .handled
    }
    
    private func handleAppleCompletion(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = AppleSignIn.credential(from: authorization) else {
                vm.appleSignInFailed()
                return
            }
            Task {
                await vm.completeAppleSignIn(
                    idToken: credential.idToken,
                    fullName: credential.fullName
                )
            }
        case .failure(let error):
            guard (error as? ASAuthorizationError)?.code != .canceled else { return }
            vm.appleSignInFailed()
        }
    }
}
