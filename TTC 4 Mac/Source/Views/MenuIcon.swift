//
//  MenuIcon.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 08/01/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

import LaunchAtLogin

struct MenuIcon: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(.toolbarIcon)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16, alignment: .center)
            .onAppear {
                // show our settings window if either we still need to gather configuration
                // or if the application's launch at login setting is off. When it's off, it's likley
                // that the user is using the app as a one-off run perhaps before starting their
                // gaming session, and a big window showing up mid-screen is much more
                // intuitive than a little menu bar extra appearing top-right...
                
                if AppModel.shared.needsConfiguration || LaunchAtLogin.isEnabled == false {
                    openWindow(id: "settings")
                }
            }
    }
}

#Preview {
    MenuIcon()
}
