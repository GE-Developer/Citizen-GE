//
//  PostgresTimestamp.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum PostgresTimestamp {
    private static let formats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSxxxxx",
        "yyyy-MM-dd'T'HH:mm:ssxxxxx",
        "yyyy-MM-dd"
    ]
    
    private static let posixLocale = Locale(identifier: "en_US_POSIX")
    
    static func date(from raw: String) -> Date? {
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoWithFraction.date(from: raw) {
            return date
        }
        
        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]
        
        if let date = isoPlain.date(from: raw) {
            return date
        }
        
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = posixLocale
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format
            
            if let date = formatter.date(from: raw) {
                return date
            }
        }
        
        return nil
    }
}
