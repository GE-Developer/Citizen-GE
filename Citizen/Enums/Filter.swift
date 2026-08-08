//
//  Filter.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Filter: Hashable {
    case all
    case named(String)
    
    @MainActor
    var title: String {
        switch self {
        case .all:
            L10n("DictionaryFilter.All.title")
        case .named(let name):
            name
        }
    }
}
