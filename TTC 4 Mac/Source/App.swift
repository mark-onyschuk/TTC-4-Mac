//
//  TTC_4_MacApp.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 by Dimension North Inc. All Rights Reserved.

import SwiftUI
import LaunchAtLogin

@main
struct TTC_4_MacApp: App {
    var body: some Scene {
        let model = AppModel.shared
        
        MenuBarExtra {
            MenuView()
                .environmentObject(model)
        } label: {
            MenuIcon()
        }

        Window("Tamriel Trade Centre Price Update Settings", id: "settings") {
            SettingsView()
                .environmentObject(model)
        }
    }
}
