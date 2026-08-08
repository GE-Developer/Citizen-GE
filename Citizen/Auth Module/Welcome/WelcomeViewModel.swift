//
//  WelcomeViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct AuthFeature: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let caption: String
}

@MainActor
@Observable
final class WelcomeViewModel {
    var isShowingLanguageSheet = false
    var selectedFeature: AuthFeature.ID? {
        didSet {
            guard selectedFeature != nil, selectedFeature != oldValue else { return }
            haptics.impact(style: .soft, vol: 0.4)
        }
    }
    
    var subtitle: String { L10n("Auth.Welcome.subtitle") }
    var signInTitle: String { L10n("Auth.SignIn.button") }
    var appleTitle: String { L10n("Auth.appleButton") }
    var orTitle: String { L10n("Auth.divider.or") }
    var switchPrompt: String { L10n("Auth.switchToSignUp.prompt") }
    var switchAction: String { L10n("Auth.switchToSignUp.action") }
    var languageSheetTitle: String { L10n("Settings.General.Language.title") }
    
    var features: [AuthFeature] {
        [
            AuthFeature(
                id: 1,
                value: L10n("Auth.Welcome.Feature1.value"),
                label: L10n("Auth.Welcome.Feature1.label"),
                caption: L10n("Auth.Welcome.Feature1.caption")
            ),
            AuthFeature(
                id: 2,
                value: L10n("Auth.Welcome.Feature2.value"),
                label: L10n("Auth.Welcome.Feature2.label"),
                caption: L10n("Auth.Welcome.Feature2.caption")
            ),
            AuthFeature(
                id: 3,
                value: L10n("Auth.Welcome.Feature3.value"),
                label: L10n("Auth.Welcome.Feature3.label"),
                caption: L10n("Auth.Welcome.Feature3.caption")
            ),
            AuthFeature(
                id: 4,
                value: L10n("Auth.Welcome.Feature4.value"),
                label: L10n("Auth.Welcome.Feature4.label"),
                caption: L10n("Auth.Welcome.Feature4.caption")
            ),
            AuthFeature(
                id: 5,
                value: L10n("Auth.Welcome.Feature5.value"),
                label: L10n("Auth.Welcome.Feature5.label"),
                caption: L10n("Auth.Welcome.Feature5.caption")
            ),
            AuthFeature(
                id: 6,
                value: L10n("Auth.Welcome.Feature6.value"),
                label: L10n("Auth.Welcome.Feature6.label"),
                caption: L10n("Auth.Welcome.Feature6.caption")
            ),
            AuthFeature(
                id: 7,
                value: L10n("Auth.Welcome.Feature7.value"),
                label: L10n("Auth.Welcome.Feature7.label"),
                caption: L10n("Auth.Welcome.Feature7.caption")
            )
        ]
    }
    
    var legalText: AttributedString {
        let source = L10n("Auth.Welcome.legal")
        return (try? AttributedString(markdown: source)) ?? AttributedString(source)
    }
    
    var currentLanguageName: String {
        Language(rawValue: languageManager.currentLanguageID)?.localizedName
        ?? Language.english.localizedName
    }
    
    private(set) var isLoading = false
    
    private var appleNonce: String?
    
    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let feedback = FeedbackManager.shared
    private let languageManager = LanguageManager.shared
    
    init() {
        selectedFeature = features.first?.id
    }
    
    func noticeBanIfNeeded() {
        guard auth.consumeBanNotice() else { return }
        showError(AuthFlowError.banned.message)
    }
    
    func startAppleSignIn() -> String {
        haptics.impact()
        let nonce = AppleSignIn.makeNonce()
        appleNonce = nonce.raw
        return nonce.hashed
    }
    
    func tapFeedback() {
        haptics.impact()
    }
    
    func showLanguageSheet() {
        haptics.impact()
        isShowingLanguageSheet = true
    }
    
    func completeAppleSignIn(idToken: String, fullName: String?) async {
        guard let nonce = appleNonce else { return }
        
        appleNonce = nil
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth
                .signInWithApple(idToken: idToken, nonce: nonce, fullName: fullName)
        } catch {
            showError(error.message)
        }
    }
    
    func appleSignInFailed() {
        showError(AuthFlowError.unknown.message)
    }
    
    func legalURL(for link: URL) -> URL? {
        
        let address = switch link.host() {
        case "terms":
            Plist.get(.termsOfUse)
        case "privacy":
            Plist.get(.privacyPolicy)
        default:
            ""
        }
        
        return URL(string: address)
    }
    
    func isCurrentLanguage(_ language: Language) -> Bool {
        language.id == languageManager.currentLanguageID
    }
    
    func setLanguage(_ language: Language) {
        guard !isCurrentLanguage(language) else { return }
        
        haptics.selectionChanged()
        languageManager.currentLanguageID = language.id
        isShowingLanguageSheet = false
        
        ProfileSync.shared.noteLocalEdit()
        Task { await AppDataLoader.shared.reload() }
    }
    
    private func showError(_ message: String) {
        haptics.impact()
        feedback.show(message, style: .error)
    }
}
