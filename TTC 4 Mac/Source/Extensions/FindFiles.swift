//
//  FindFiles.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Foundation

extension FileManager {
    static func find(fileName: String, in directory: URL) async -> URL? {
        return await Task<URL?, Never> {
            let manager = FileManager()
            let enumerator = manager.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey, .isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants],
                errorHandler: { url, error in print(error.localizedDescription); return false }
            )
            while let url = enumerator?.nextObject() as? URL {
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey])
                    if let isUbiquitous = resourceValues.isUbiquitousItem, isUbiquitous {
                        print("\(url.lastPathComponent) is in iCloud")
                        // You can trigger a download if necessary
                        try manager.startDownloadingUbiquitousItem(at: url)
                    }
                    if url.lastPathComponent == fileName {
                        return url
                    }
                } catch {
                    print("Error retrieving resource values for \(url): \(error.localizedDescription)")
                }
            }
            return nil
        }.value
    }}
