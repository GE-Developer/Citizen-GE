//
//  ContactCategory.swift
//  Citizen
//
//  Created by GE-Developer
//

enum ContactCategory: String, CaseIterable, Identifiable, Sendable {
    case privateTutor = "Private Tutor"
    case languageCourses = "Language Courses"
    case legal = "Legal"
    case translationNotary = "Translation & Notary"
    case migration = "Migration"
    case links = "Links"
    
    var id: String { rawValue }
    
    @MainActor
    var title: String {
        switch self {
        case .legal:
            return L10n("Contacts.Category.legal.title")
        case .translationNotary:
            return L10n("Contacts.Category.translationNotary.title")
        case .migration:
            return L10n("Contacts.Category.migration.title")
        case .languageCourses:
            return L10n("Contacts.Category.languageCourses.title")
        case .privateTutor:
            return L10n("Contacts.Category.privateTutor.title")
        case .links:
            return L10n("Contacts.Category.links.title")
        }
    }
}
