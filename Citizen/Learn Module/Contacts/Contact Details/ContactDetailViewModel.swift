//
//  ContactDetailViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreGraphics
import Foundation

@MainActor
@Observable
final class ContactDetailViewModel {
    var showMethods = false
    var showAccessAlert = false
    var showSaveError = false
    
    private(set) var isSaved = false
    private(set) var isSaving = false
    
    let heading: String
    let affiliation: String?
    let subtitle: String?
    let about: String?
    let workingHours: String?
    let priceText: String?
    let languagesText: String?
    let isCompany: Bool
    let isVerified: Bool
    let photoURL: String?
    let categoryTitle: String
    let methods: [ContactMethod]
    
    let title = L10n("Contacts.Detail.title")
    let aboutTitle = L10n("Contacts.Detail.about.title")
    let languagesTitle = L10n("Contacts.Detail.languages.title")
    let hoursTitle = L10n("Contacts.Detail.hours.title")
    let priceTitle = L10n("Contacts.Detail.price.title")
    let methodsTitle = L10n("Contacts.Detail.methods.title")
    let addToPhoneTitle = L10n("Contacts.Action.addToPhone")
    let addedToPhoneTitle = L10n("Contacts.Action.addedToPhone")
    let accessAlertTitle = L10n("Contacts.Save.denied.title")
    let accessAlertMessage = L10n("Contacts.Save.denied.message")
    let openSettingsTitle = L10n("Contacts.Save.openSettings")
    let saveErrorTitle = L10n("Contacts.Save.failed")
    let cancelTitle = L10n("SearchField.cancel")
    
    private let contact: Contact
    private let info: LocalizedContact
    private let phoneContacts = PhoneContactsService.shared
    private let images = RemoteImageStore.shared
    private let haptics = HapticsManager.shared
    
    init(contact: Contact) {
        let info = contact.publicData[LanguageManager.shared.currentLanguageID]
        ?? contact.publicData["en"]
        ?? contact.publicData.values.first
        ?? .empty
        
        self.contact = contact
        self.info = info
        
        isCompany = contact.isCompany
        isVerified = contact.isVerified
        photoURL = contact.photoURL
        categoryTitle = ContactCategory(rawValue: contact.category)?.title
        ?? L10n("Contacts.Category.other.title")
        
        let fullName = [info.name, info.surname]
            .compactMap { $0?.nonEmpty }
            .joined(separator: " ")
        
        heading = fullName.isEmpty ? (info.company?.nonEmpty ?? "-") : fullName
        affiliation = fullName.isEmpty ? nil : info.company?.nonEmpty
        subtitle = info.subtitle?.nonEmpty
        about = info.description?.nonEmpty
        workingHours = info.workingHours?.nonEmpty
        
        priceText = Self.priceText(
            from: contact.priceFrom,
            fix: contact.priceFix,
            fromWord: L10n("Contacts.Detail.price.from")
        )
        
        let names = contact.languages
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        languagesText = names.isEmpty ? nil : names.joined(separator: " · ")
        
        methods = Self.methods(for: contact, info: info)
    }
    
    func contactInfoButtonPressed() {
        haptics.impact()
        showMethods = true
    }
    
    func methodPressed() {
        haptics.impact(style: .light)
    }
    
    func addToPhoneContactsPressed() async {
        guard !isSaving, !isSaved else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await phoneContacts.save(
                contact,
                info: info,
                methods: methods,
                photo: await photoData()
            )
            haptics.notification(type: .success)
            isSaved = true
        } catch PhoneContactsService.Failure.accessDenied {
            showAccessAlert = true
        } catch {
            showSaveError = true
        }
    }
    
    private func photoData() async -> Data? {
        guard let url = contact.photoURL?.nonEmpty,
              let image = await images.image(for: url) else { return nil }
        
        return PhoneContactsService.pngData(from: image)
    }
    
    private static func methods(
        for contact: Contact,
        info: LocalizedContact
    ) -> [ContactMethod] {
        ContactMethodKind.allCases.compactMap { kind in
            guard let url = url(for: kind, contact: contact, info: info) else { return nil }
            
            return ContactMethod(kind: kind, title: kind.title, url: url)
        }
    }
    
    private static func url(
        for kind: ContactMethodKind,
        contact: Contact,
        info: LocalizedContact
    ) -> URL? {
        switch kind {
        case .phone:
            return telURL(contact.phone)
        case .whatsapp:
            return whatsappURL(contact.whatsapp)
        case .telegram:
            return telegramURL(contact.telegram)
        case .instagram:
            return instagramURL(contact.instagram)
        case .email:
            return mailtoURL(contact.email)
        case .website:
            return webURL(contact.website)
        case .address:
            return mapURL(info.address)
        }
    }
    
    private static func priceText(from: Int?, fix: Int?, fromWord: String) -> String? {
        var parts: [String] = []
        if let from {
            parts.append("\(fromWord) \(from) ₾")
        }
        
        if let fix {
            parts.append("\(fix) ₾")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
    
    private static func telURL(_ phone: String?) -> URL? {
        guard let phone = phone?.nonEmpty else { return nil }
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        
        guard !digits.isEmpty else { return nil }
        
        return URL(string: "tel:\(digits)")
    }
    
    private static func mailtoURL(_ email: String?) -> URL? {
        guard let email = email?.nonEmpty else { return nil }
        return URL(string: "mailto:\(email)")
    }
    
    private static func webURL(_ site: String?) -> URL? {
        guard let site = site?.nonEmpty else { return nil }
        if site.hasPrefix("http://") || site.hasPrefix("https://") {
            return URL(string: site)
        }
        
        return URL(string: "https://\(site)")
    }
    
    private static func telegramURL(_ raw: String?) -> URL? {
        guard let raw = raw?.nonEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        
        let handle = raw.hasPrefix("@") ? String(raw.dropFirst()) : raw
        
        return URL(string: "https://t.me/\(handle)")
    }
    
    private static func instagramURL(_ raw: String?) -> URL? {
        guard let raw = raw?.nonEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        
        let handle = raw.hasPrefix("@") ? String(raw.dropFirst()) : raw
        
        return URL(string: "https://instagram.com/\(handle)")
    }
    
    private static func whatsappURL(_ raw: String?) -> URL? {
        guard let raw = raw?.nonEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        
        let digits = raw.filter { $0.isNumber }
        
        guard !digits.isEmpty else { return nil }
        
        return URL(string: "https://wa.me/\(digits)")
    }
    
    private static func mapURL(_ address: String?) -> URL? {
        guard let address = address?.nonEmpty,
              let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return nil }
        
        return URL(string: "https://maps.apple.com/?q=\(encoded)")
    }
}
