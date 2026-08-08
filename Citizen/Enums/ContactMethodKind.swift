//
//  ContactMethodKind.swift
//  Citizen
//
//  Created by GE-Developer
//

enum ContactMethodKind: String, CaseIterable, Identifiable, Sendable {
    case phone
    case whatsapp
    case telegram
    case instagram
    case email
    case website
    case address
    
    var id: String { rawValue }
    
    @MainActor
    var title: String {
        switch self {
        case .phone:
            return L10n("Contacts.Action.call")
        case .whatsapp:
            return L10n("Contacts.Action.whatsapp")
        case .telegram:
            return L10n("Contacts.Action.telegram")
        case .instagram:
            return L10n("Contacts.Action.instagram")
        case .email:
            return L10n("Contacts.Action.email")
        case .website:
            return L10n("Contacts.Action.website")
        case .address:
            return L10n("Contacts.Action.address")
        }
    }
}
