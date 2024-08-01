//
//  SecurityScopedURL.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/22/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Foundation


/// An URL whose contents must be accessed in a secure fashion.
///
/// SecurityScopedURL instances are usually created as result of user
/// interaction with an OpenPanel, where the user is granted some measure
/// of temporary access to files they have explicitly selected.
struct SecurityScopedURL: Codable, Equatable {
    
    /// SecurityScopedURL errors
    enum Error: Swift.Error {
        case inaccessibleResolvedURL /// the URL was resolved, but otherwise inaccessible
    }
    
    var url:  URL
    var data: Data
    
    init(_ url: URL) throws {
        self.url  = url
        self.data = try url.bookmarkData(
            options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil
        )
    }
    
    /// Performs `action` using a secured reference to the receiver's `url`. If the receiver is stale, `refresh` the receiver
    /// within the caller.
    ///
    /// - Parameters:
    ///   - action: an action performed on a secured reference to the receiver's `url`
    ///   - refresh: an action performed to store a fresh copy of the receiver, in case the current copy is stale.
    /// - Returns: a `Result`
    func securely<Result>(perform action: (URL) throws -> Result, refresh: (SecurityScopedURL)->Void) throws -> Result {
        var stale = false
        let resolved = try URL(
            resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale
        )
        
        if stale {
            try refresh(SecurityScopedURL(resolved))
        }
        
        if resolved.startAccessingSecurityScopedResource() {
            defer { resolved.stopAccessingSecurityScopedResource() }
            
            return try action(resolved)
        } else {
            throw Error.inaccessibleResolvedURL
        }
    }
    
    mutating func securely<Result>(perform action: (URL) throws -> Result) throws -> Result {
        try securely(perform: action) {
            refreshed in self = refreshed
        }
    }
}
