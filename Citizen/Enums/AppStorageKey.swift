//
//  AppStorageKey.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppStorageKey {
    // MARK: - User Settings
    case theme
    case haptics
    case language
    case sound
    case voiceActing
    case shuffleAnswers
    case shuffleQuestions
    case accentColor
    case screenshotProtection
    
    // MARK: - Resource Downloader
    case resourcesVersion
    case contentVersions
    case mediaVersions
    
    // MARK: - Account
    case installMarker
    case userNickname
    case userMood
    case userDataUpdatedAt
    case userAvatarURL
    case avatarUploadPending
    case passwordAuthUserIDs
    case identityDirtyFields
    
    // MARK: - Grants
    case grantPremium
    case grantDevPassword
    case grantMessage
    case serverPremium
    
    // MARK: - Contacts
    case contactsUpdatedAt
    case contactsCount
    
    // MARK: - Progress Sync State
    case syncLocalChangeCount
    case syncSyncedChangeCount
    case syncLastLocalChangeAt
    case syncServerUpdatedAt
    case syncLastUserID
    
    var key: String {
        switch self {
        case .theme: return "isDarkMode"
        case .haptics: return "isHapticsOn"
        case .language: return "AppleLanguages"
        case .sound: return "isSoundOn"
        case .voiceActing: return "isVoiceActingOn"
        case .shuffleAnswers: return "isShuffleAnswersOn"
        case .shuffleQuestions: return "isShuffleQuestionsOn"
        case .accentColor: return "accentColor"
        case .screenshotProtection: return "screenshotProtection"
        case .resourcesVersion: return "resourcesAppVersion"
        case .contentVersions: return "contentVersions"
        case .mediaVersions: return "mediaVersions"
        case .installMarker: return "installMarker"
        case .userNickname: return "userNickname"
        case .userMood: return "userMood"
        case .userDataUpdatedAt: return "userDataUpdatedAt"
        case .userAvatarURL: return "userAvatarURL"
        case .avatarUploadPending: return "avatarUploadPending"
        case .passwordAuthUserIDs: return "passwordAuthUserIDs"
        case .identityDirtyFields: return "identityDirtyFields"
        case .grantPremium: return "grantPremium"
        case .grantDevPassword: return "grantDevPassword"
        case .serverPremium: return "serverPremium"
        case .grantMessage: return "grantMessage"
        case .contactsUpdatedAt: return "contactsUpdatedAt"
        case .contactsCount: return "contactsCount"
        case .syncLocalChangeCount: return "syncLocalChangeCount"
        case .syncSyncedChangeCount: return "syncSyncedChangeCount"
        case .syncLastLocalChangeAt: return "syncLastLocalChangeAt"
        case .syncServerUpdatedAt: return "syncServerUpdatedAt"
        case .syncLastUserID: return "syncLastUserID"
        }
    }
}
