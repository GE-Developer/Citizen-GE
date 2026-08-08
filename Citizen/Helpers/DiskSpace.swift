//
//  DiskSpace.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum DiskSpace {
    static var outOfSpaceError: CocoaError {
        CocoaError(.fileWriteOutOfSpace)
    }
    
    private static var availableBytes: Int64 {
        let url = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        
        let values = try? url.resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey]
        )
        
        return values?.volumeAvailableCapacityForImportantUsage ?? .max
    }
    
    private static let criticalFreeSpaceBytes: Int64 = 20 * 1024 * 1024
    
    static func hasHeadroom(_ bytes: Int64) -> Bool {
        availableBytes >= bytes
    }
    
    static var isCriticallyLow: Bool {
        !hasHeadroom(criticalFreeSpaceBytes)
    }
    
    static func isOutOfSpace(_ error: any Error) -> Bool {
        var current: (any Error)? = error
        
        while let error = current {
            let nsError = error as NSError
            
            if nsError.domain == NSCocoaErrorDomain,
               nsError.code == NSFileWriteOutOfSpaceError {
                return true
            }
            
            if nsError.domain == NSPOSIXErrorDomain,
               nsError.code == Int(ENOSPC) {
                return true
            }
            
            current = nsError.userInfo[NSUnderlyingErrorKey] as? any Error
        }
        
        return false
    }
}
