//
//  SettingsView.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Settings")) {
                    setRegion
                    setAddonPath
                }
                Section(header: Text("Launch Settings")) {
                    setLaunchAtLogin
                }
            }
            .font(.headline)
            .formStyle(.grouped)
            
            actions
                .padding()
        }
    }

    @ViewBuilder
    var setRegion: some View {
        Text(Localizable.regionText)
            .font(.callout)
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden, edges: .bottom)
            .padding(.horizontal)
        
        Picker(regionTitle, selection: $model.gameRegion) {
            ForEach(AppModel.Region.allCases) { region in
                Text(region.rawValue).tag(region)
            }
        }
        .pickerStyle(.inline)
    }
    
    @ViewBuilder
    var setAddonPath: some View {
        Text(Localizable.addonText)
            .font(.callout)
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden, edges: .bottom)
            .padding(.horizontal)
        
        HStack {
            if model.isSearchingForAddOnURL {
                Text("Searching")
                ProgressView()
                    .controlSize(.small)
                    .progressViewStyle(.circular)
            } else if let pluginUrl = model.addOnURL {
                PathControl(url: pluginUrl.url).padding(.trailing)
            } else {
                Text("Find My TTC Add-On")
            }
            
            Spacer()
            Button(action: findAddOns) {
                Text(model.addOnURL == nil
                     ? "Search"
                     : "Find My TTC Add-On"
                )
                .foregroundStyle(.blue)
                .opacity(model.isSearchingForAddOnURL ? 0.5 : 1.0)
            }
            .buttonStyle(.borderless)
            .disabled(model.isSearchingForAddOnURL)
        }
    }
    
    @ViewBuilder
    var setLaunchAtLogin: some View {
        Text(Localizable.launchText)
            .font(.callout)
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden, edges: .bottom)
            .padding(.horizontal)
        
        LaunchAtLogin
            .Toggle()
            .toggleStyle(.switch)
    }

    @ViewBuilder
    var actions: some View {
        let canUpdate = model.canUpdatePrices
        let isUpdating = model.isUpdatingPrices

        HStack {
            if let date = model.lastUpdate {
                Group {
                    Text("Last Update:")
                    Text(date.formatted(.relative(presentation: .named)))
                }.foregroundStyle(.secondary)
            }

            Spacer()
            
            
            if isUpdating {
                ProgressView()
                    .controlSize(.small)
                    .progressViewStyle(.circular)
            }
            
            Button(action: updateAddOn) {
                Text("Update Now")
            }
            .disabled(isUpdating)
        }
        .disabled(!canUpdate)
    }
    
    var regionTitle: LocalizedStringKey {
        switch model.gameRegion {
        case let region?:
            "Download Prices For \(region.rawValue) Servers"
        case nil:
            "Select Region"
        }
    }
    
    func findAddOns() {
        Task {
            await model.searchForPluginUrl()
        }
    }

    func updateAddOn() {
        model.updatePrices()
    }
    
    func quit() {
        NSApplication.shared.terminate(self)
    }
}

enum Localizable {}

extension Localizable {
    static let addonText: LocalizedStringKey = """
    The [Tamriel Trade Centre](https://us.tamrieltradecentre.com) add-on displays prices for guild-auctioned goods. Locate your copy of the add-on to ensure fresh prices are copied to the right place! 
    """
    
    static let regionText: LocalizedStringKey = """
    [Elder Scrolls Online](https://www.elderscrollsonline.com) runs separate servers, each with their own unique prices, for both US and EU customers. Select the region you want to fetch prices for!
    """
    
    static let launchText: LocalizedStringKey = """
    Add **TTC 4 Mac** to the list of apps started at launch, and keep your daily price list fresh each time you play the [Elder Scrolls Online](https://www.elderscrollsonline.com)!
    """
}

#Preview {
    SettingsView().environmentObject(AppModel())
}
