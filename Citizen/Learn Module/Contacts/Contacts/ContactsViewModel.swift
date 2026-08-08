//
//  ContactsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct ContactSection: Identifiable {
    let category: ContactCategory?
    let title: String
    let contacts: [Contact]
    
    var id: String { category?.rawValue ?? "__other__" }
}

@MainActor
@Observable
final class ContactsViewModel {
    enum Phase {
        case loading
        case loaded
        case failed
    }
    
    var selectedContact: Contact?
    
    private(set) var phase: Phase = .loading
    private(set) var sections: [ContactSection] = []
    
    let title = L10n("Main.Contacts.title")
    let emptyTitle = L10n("Contacts.Empty.title")
    let emptyMessage = L10n("Contacts.Empty.message")
    let failureTitle = L10n("Error.title")
    
    private let store = ContactsStore.shared
    private let languageManager = LanguageManager.shared
    
    init() {
        rebuild()
        phase = sections.isEmpty ? .loading : .loaded
    }
    
    func load() async {
        if sections.isEmpty {
            phase = .loading
        }
        
        do {
            try await store.syncIfChanged()
            rebuild()
            phase = .loaded
        } catch {
            if sections.isEmpty {
                phase = .failed
            }
        }
    }
    
    func select(_ contact: Contact) {
        selectedContact = contact
    }
    
    func displayName(for contact: Contact) -> String {
        let info = resolved(contact)
        let full = [info.name, info.surname]
            .compactMap { $0?.nonEmpty }
            .joined(separator: " ")
        
        if !full.isEmpty {
            return full
        }
        
        return info.company?.nonEmpty ?? "-"
    }
    
    func subtitle(for contact: Contact) -> String? {
        resolved(contact).subtitle?.nonEmpty
    }
    
    func photoURL(for contact: Contact) -> String? {
        contact.photoURL
    }
    
    private func rebuild() {
        let now = Date()
        let visible = store.contacts.filter { contact in
            guard contact.isActive else { return false }
            guard let expires = contact.expiresAt else { return true }
            
            return expires > now
        }
        
        var result: [ContactSection] = []
        
        for category in ContactCategory.allCases {
            let items = sortedInSection(visible.filter { $0.category == category.rawValue })
            guard !items.isEmpty else { continue }
            result.append(
                ContactSection(category: category, title: category.title, contacts: items)
            )
        }
        
        let known = Set(ContactCategory.allCases.map(\.rawValue))
        let others = sortedInSection(visible.filter { !known.contains($0.category) })
        
        if !others.isEmpty {
            result.append(
                ContactSection(
                    category: nil,
                    title: L10n("Contacts.Category.other.title"),
                    contacts: others
                )
            )
        }
        
        sections = result
    }
    
    private func sortedInSection(_ contacts: [Contact]) -> [Contact] {
        var decorated: [(key: (Int, String), contact: Contact)] = []
        decorated.reserveCapacity(contacts.count)
        for contact in contacts {
            let key = (contact.isVerified ? 0 : 1, displayName(for: contact).lowercased())
            decorated.append((key, contact))
        }
        
        return decorated
            .sorted { $0.key < $1.key }
            .map(\.contact)
    }
    
    private func resolved(_ contact: Contact) -> LocalizedContact {
        contact.publicData[languageManager.currentLanguageID]
        ?? contact.publicData["en"]
        ?? contact.publicData.values.first
        ?? .empty
    }
}
