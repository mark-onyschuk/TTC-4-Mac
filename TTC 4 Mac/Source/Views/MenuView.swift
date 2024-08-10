//
//  MenuView.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 by Dimension North Inc. All Rights Reserved.

import SwiftUI
import LaunchAtLogin

struct MenuView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    
    var region: String {
        model.gameRegion?.rawValue ?? "-"
    }
    var lastUpdated: String {
        model.lastUpdate?.formatted(.relative(presentation: .named)).capitalized ?? "Never"
    }
    var body: some View {
        Group {
            Text("Region: \(region)")
                .font(.body).fontWeight(.bold)
            Text("Last Updated: \(lastUpdated)")
                .font(.body).bold()

            if model.error != nil {
                Divider()
                Label {
                    Text("Price Update Error")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }

            }
            Divider()
            Button("Update Prices Now") {
                updatePrices()
            }.disabled(model.isUpdatingPrices)

            Divider()
            Button("Settings...") {
                openWindow(id: "settings")
            }
            
            Divider()
            Button("Quit") {
                NSApp.terminate(self)
            }
        }
    }
    
    func updatePrices() {
        model.updatePrices()
    }
}

#Preview {
    MenuView()
}
