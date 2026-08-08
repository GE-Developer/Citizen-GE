//
//  Contact.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct Contact: Codable, Sendable, Identifiable, Hashable {
    var expiresAt: Date? {
        guard let expiresAtRaw, !expiresAtRaw.isEmpty,
              let parsed = PostgresTimestamp.date(from: expiresAtRaw) else { return nil }
        
        return expiresAtRaw.contains("T") ? parsed : parsed.addingTimeInterval(24 * 60 * 60)
    }
    
    let id: UUID
    let category: String
    let isCompany: Bool
    let isVerified: Bool
    let isActive: Bool
    let photoURL: String?
    let languages: [String]
    let phone: String?
    let email: String?
    let website: String?
    let telegram: String?
    let whatsapp: String?
    let instagram: String?
    let priceFrom: Int?
    let priceFix: Int?
    let expiresAtRaw: String?
    let publicData: [String: LocalizedContact]
    
    enum CodingKeys: String, CodingKey {
        case id, category, phone, email, website, telegram, whatsapp, instagram
        case isCompany = "is_company"
        case isVerified = "is_verified"
        case isActive = "is_active"
        case photoURL = "image_url"
        case languages = "language"
        case priceFrom = "price_from"
        case priceFix = "price_fix"
        case expiresAtRaw = "expires_at"
        case publicData = "public_data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        category = (try? container.decode(String.self, forKey: .category)) ?? ""
        isCompany = (try? container.decode(Bool.self, forKey: .isCompany)) ?? false
        isVerified = (try? container.decode(Bool.self, forKey: .isVerified)) ?? false
        isActive = (try? container.decode(Bool.self, forKey: .isActive)) ?? true
        photoURL = try? container.decode(String.self, forKey: .photoURL)
        languages = (try? container.decode([String].self, forKey: .languages)) ?? []
        phone = try? container.decode(String.self, forKey: .phone)
        email = try? container.decode(String.self, forKey: .email)
        website = try? container.decode(String.self, forKey: .website)
        telegram = try? container.decode(String.self, forKey: .telegram)
        whatsapp = try? container.decode(String.self, forKey: .whatsapp)
        instagram = try? container.decode(String.self, forKey: .instagram)
        priceFrom = try? container.decode(Int.self, forKey: .priceFrom)
        priceFix = try? container.decode(Int.self, forKey: .priceFix)
        expiresAtRaw = try? container.decode(String.self, forKey: .expiresAtRaw)
        publicData = (try? container.decode([String: LocalizedContact].self, forKey: .publicData)) ?? [:]
    }
}

struct LocalizedContact: Codable, Sendable, Hashable {
    let name: String?
    let surname: String?
    let company: String?
    let subtitle: String?
    let workingHours: String?
    let description: String?
    let address: String?
    
    static let empty = LocalizedContact(
        name: nil,
        surname: nil,
        company: nil,
        subtitle: nil,
        workingHours: nil,
        description: nil,
        address: nil
    )
    
    enum CodingKeys: String, CodingKey {
        case name, surname, company, subtitle, description, address
        case workingHours = "working_hours"
    }
}
