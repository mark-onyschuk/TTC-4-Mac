//
//  AsyncOpen.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

extension NSOpenPanel {
    struct OpenOptions: OptionSet {
        let rawValue: Int
        
        static let selectFile = OpenOptions(rawValue: 1 << 0)
        static let selectDirectory = OpenOptions(rawValue: 1 << 1)
        static let allowsMultipleSelection = OpenOptions(rawValue: 1 << 2)
    }
    
    static func open(prompt: String? = nil, message: String? = nil, options: OpenOptions) async -> [URL]? {
        await withCheckedContinuation { continuation in
            let panel = NSOpenPanel()
            panel.prompt = prompt
            panel.message = message
            
            panel.canChooseFiles = options.contains(.selectFile)
            panel.canChooseDirectories = options.contains(.selectDirectory)
            panel.allowsMultipleSelection = options.contains(.allowsMultipleSelection)

            panel.begin { response in
                if response == .OK {
                    continuation.resume(returning: panel.urls)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
