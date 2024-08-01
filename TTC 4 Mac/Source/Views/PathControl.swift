//
//  PathControl.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

struct PathControl: NSViewRepresentable {
    var url: URL?

    func makeNSView(context: Context) -> NSPathControl {
        let pathControl = NSPathControl()
        pathControl.action = #selector(Coordinator.pathItemClicked(_:))
        pathControl.target = context.coordinator
        
        pathControl.pathStyle = .standard
        
        return pathControl
    }

    func updateNSView(_ nsView: NSPathControl, context: Context) {
        nsView.url = url
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSPathControl, context: Context) -> CGSize? {
        guard let proposedWidth = proposal.width else { return nil }
        return CGSize(width: proposedWidth, height: nsView.fittingSize.height)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PathControl

        init(_ parent: PathControl) {
            self.parent = parent
        }

        @objc func pathItemClicked(_ sender: NSPathControl) {
            parent.url = sender.url
        }
    }
}
