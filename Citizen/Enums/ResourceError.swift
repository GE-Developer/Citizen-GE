//
//  ResourceError.swift
//  Citizen
//
//  Created by GE-Developer
//


enum ResourceError: Error {
    case loadFailed(String)
    case invalidData(String)
}
