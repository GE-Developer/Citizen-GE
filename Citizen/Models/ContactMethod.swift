//
//  ContactMethod.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct ContactMethod: Identifiable, Sendable, Hashable {
    let kind: ContactMethodKind
    let title: String
    let url: URL

    var id: String { kind.rawValue }
}
