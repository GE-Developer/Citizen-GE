//
//  PhoneContactsService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Contacts
import ImageIO
import UniformTypeIdentifiers

struct PhoneContactsService: Sendable {
    enum Failure: Error {
        case accessDenied
        case saveFailed
    }
    
    static let shared = PhoneContactsService()
    
    private init() {}
    
    func save(
        _ contact: Contact,
        info: LocalizedContact,
        methods: [ContactMethod],
        photo: Data?
    ) async throws {
        let granted = (try? await CNContactStore().requestAccess(for: .contacts)) ?? false
        guard granted else { throw Failure.accessDenied }
        
        try await Task.detached {
            try Self.write(contact, info: info, methods: methods, photo: photo)
        }.value
    }
    
    static func pngData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else { return nil }
        
        CGImageDestinationAddImage(destination, image, nil)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
    private static func write(
        _ contact: Contact,
        info: LocalizedContact,
        methods: [ContactMethod],
        photo: Data?
    ) throws {
        let card = CNMutableContact()
        
        card.imageData = photo
        card.givenName = info.name?.nonEmpty ?? ""
        card.familyName = info.surname?.nonEmpty ?? ""
        card.organizationName = info.company?.nonEmpty ?? ""
        card.jobTitle = info.subtitle?.nonEmpty ?? ""
        
        if card.givenName.isEmpty && card.familyName.isEmpty && card.organizationName.isEmpty {
            throw Failure.saveFailed
        }
        
        if let phone = contact.phone?.nonEmpty {
            card.phoneNumbers = [
                CNLabeledValue(
                    label: CNLabelPhoneNumberMobile,
                    value: CNPhoneNumber(stringValue: phone)
                )
            ]
        }
        
        if let email = contact.email?.nonEmpty {
            card.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email as NSString)]
        }
        
        card.urlAddresses = methods.compactMap { method in
            guard let label = urlLabel(for: method.kind) else { return nil }
            
            return CNLabeledValue(label: label, value: method.url.absoluteString as NSString)
        }
        
        if let address = info.address?.nonEmpty {
            let postal = CNMutablePostalAddress()
            postal.street = address
            card.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: postal)]
        }
        
        let request = CNSaveRequest()
        request.add(card, toContainerWithIdentifier: nil)
        
        do {
            try CNContactStore().execute(request)
        } catch {
            throw Failure.saveFailed
        }
    }
    
    private static func urlLabel(for kind: ContactMethodKind) -> String? {
        switch kind {
        case .website:
            return CNLabelURLAddressHomePage
        case .telegram:
            return "Telegram"
        case .instagram:
            return "Instagram"
        case .whatsapp:
            return "WhatsApp"
        case .phone, .email, .address:
            return nil
        }
    }
}
