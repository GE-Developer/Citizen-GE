//
//  SettingsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet { themeManager.isDarkMode = isDarkMode }
    }
    
    @Published var isHapticsOn: Bool {
        didSet { hapticsManager.isHapticsOn = isHapticsOn }
    }
    
    @Published var isSoundOn: Bool {
        didSet { soundManager.isSoundOn = isSoundOn }
    }
    
    @Published var isVoiceActingOn: Bool {
        didSet { voiceActingManager.isVoiceActingOn = isVoiceActingOn }
    }
    
    @Published var isShuffleAnswersOn: Bool {
        didSet { shuffleAnswersManager.isShuffleAnswersOn = isShuffleAnswersOn }
    }
    
    @Published var isShuffleQuestionsOn: Bool {
        didSet { shuffleQuestionsManager.isShuffleQuestionsOn = isShuffleQuestionsOn }
    }
    
    var title: String {
        L10n("Settings.title")
    }
    
    var generalSettingsTitle: String {
        L10n("Settings.General.title")
    }
    
    var darkModeTitle: String {
        L10n("Settings.General.DarkMode.title")
    }
    
    var languageTitle: String {
        L10n("Settings.General.Language.title")
    }
    
    var language: String {
        Language(rawValue: languageManager.currentLanguageID)?.localizedName ?? ""
    }
    
    var hapticsTitle: String {
        L10n("Settings.General.Haptics.title")
    }
    
    var soundTitle: String {
        L10n("Settings.General.Sound.title")
    }
    
    var testsSettingsTitle: String {
        L10n("Settings.Tests.title")
    }
    
    var voiceActingToggleTitle: String {
        L10n("Settings.Tests.VoiceActing.title")
    }
    
    var shuffleAnswersToggleTitle: String {
        L10n("Settings.Tests.Shuffle.title")
    }
    
    var shuffleQuestionsToggleTitle: String {
        L10n("Settings.Tests.ShuffleQuestions.title")
    }
    
    var shuffleQuestionsToggleSubtitle: String {
        L10n("Settings.Tests.ShuffleQuestions.subtitle")
    }
    
    var customizationTitle: String {
        L10n("Settings.Customization.title")
    }
    
    var appIconTitle: String {
        L10n("Settings.Customization.AppIcon.title")
    }
    
    var styleTitle: String {
        L10n("Settings.Customization.Style.title")
    }
    
    var aboutAppTitle: String {
        L10n("Settings.AboutApp.title")
    }
    
    var accountTitle: String {
        L10n("Settings.Account.title")
    }
    
    var accountNickname: String? {
        let nickname = ProfileSync.shared.nickname
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return nickname.isEmpty ? nil : nickname
    }
    
    var accountAvatar: CGImage? {
        AvatarStore.shared.avatar
    }
    
    var termsOfUseTitle: String {
        L10n("Settings.AboutApp.TermsOfUse.title")
    }
    
    var privacyPolicyTitle: String {
        L10n("Settings.AboutApp.PrivacyPolicy.title")
    }
    
    var projectTitle: String {
        L10n("Settings.AboutApp.Project.title")
    }
    
    let languageSubtitle = "Language"
    
    private let themeManager = ThemeManager.shared
    private let languageManager = LanguageManager.shared
    private let hapticsManager = HapticsManager.shared
    private let soundManager = SoundManager.shared
    private let voiceActingManager = VoiceActingManager.shared
    private let shuffleAnswersManager = ShuffleAnswersManager.shared
    private let shuffleQuestionsManager = ShuffleQuestionsManager.shared
    
    init() {
        isDarkMode = themeManager.isDarkMode
        isHapticsOn = hapticsManager.isHapticsOn
        isSoundOn = soundManager.isSoundOn
        isVoiceActingOn = voiceActingManager.isVoiceActingOn
        isShuffleAnswersOn = shuffleAnswersManager.isShuffleAnswersOn
        isShuffleQuestionsOn = shuffleQuestionsManager.isShuffleQuestionsOn
    }
    
    func showPrivacyPolicy() {
        guard let url = URL(string: Plist.get(.privacyPolicy)) else { return }
        UIApplication.shared.open(url)
    }
    
    func showTermsOfUse() {
        guard let url = URL(string: Plist.get(.termsOfUse)) else { return }
        UIApplication.shared.open(url)
    }
}
