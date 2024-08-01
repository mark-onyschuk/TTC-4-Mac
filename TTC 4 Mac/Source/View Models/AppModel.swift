//
//  AppModel.swift
//  TTC 4 Mac
//
//  Created by Mark Onyschuk on 07/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Silo
import ZipArchive

import SwiftUI
import Combine

@MainActor
final class AppModel: ObservableObject {
    static var shared: AppModel = AppModel()
    
    enum Region: String, Codable, CaseIterable, Identifiable {
        case us = "US"
        case eu = "EU"
        
        var id: String { self.rawValue }
    }
    
    @Published var isUpdatingPrices: Bool = false
    @Published var isSearchingForAddOnURL: Bool = false

    @Default(.local("lastUpdate")) var lastUpdate: Date? {
        willSet { objectWillChange.send() }
    }
    @Default(.local("gameRegion")) var gameRegion: Region? {
        willSet { objectWillChange.send() }
    }
    @Default(.local("securityScopedPluginURL")) var addOnURL: SecurityScopedURL? {
        willSet { objectWillChange.send() }
    }

    var pricingURL: URL? {
        switch gameRegion {
        case .us:
            URL(string: "https://us.tamrieltradecentre.com/download/PriceTable")
        case .eu:
            URL(string: "https://eu.tamrieltradecentre.com/download/PriceTable")
        case nil:
            nil
        }
    }
    
    func searchForPluginUrl() async {
        if isSearchingForAddOnURL {
            return
        }
        
        isSearchingForAddOnURL = true
        defer { isSearchingForAddOnURL = false }
        
        guard let directory = await NSOpenPanel.open(
            prompt: "Search Here",
            options: .selectDirectory)?.first
        else {
            return
        }
        
        do {
            addOnURL = try await FileManager.find(fileName: "TamrielTradeCentre", in: directory).map(SecurityScopedURL.init)
        }
        catch {
            print(#function, error.localizedDescription)
        }
    }
    
    var canUpdatePrices: Bool {
        !needsConfiguration
    }

    var needsConfiguration: Bool {
        addOnURL == nil || pricingURL == nil
    }

    func updatePrices() {
        Task {
            guard let pricingURL else {
                return
            }
            guard canUpdatePrices else {
                return
            }
            guard !isUpdatingPrices else {
                return
            }
            
            isUpdatingPrices = true
            defer { isUpdatingPrices = false }
            
            do {
                let session = URLSession.shared
                let request = URLRequest(url: pricingURL)
                
                let (data, _) = try await session.data(for: request)
                
                let name = UUID().uuidString
                let temp = URL.temporaryDirectory.appendingPathComponent(name).appendingPathExtension("zip")
                
                try data.write(to: temp)
                
                let saved = try addOnURL?.securely {
                    pluginUrl in SSZipArchive.unzipFile(
                        atPath: temp.path(percentEncoded: false),
                        toDestination: pluginUrl.path(percentEncoded: false)
                    )
                }
                
                if saved ?? false {
                    lastUpdate = Date()
                }
            }
            catch {
                print(#function, error)
            }
        }
    }
    
    /// timer used to send periodic observable updates to our clients
    /// who need to display up-to-date time since last update information
    var timer: AnyCancellable?
    
    @Default(.local("updateInterval")) private var updateInterval: TimeInterval = 60 * 60 * 3

    func tick() {
        objectWillChange.send()
    }
    
    func startUpdateTimer() {
        guard timer == nil else { return }
        timer = Timer.publish(every: 60.0, on: .main, in: .common).autoconnect().sink {
            [weak self] _ in
            
            guard let self else {
                return
            }
            
            let now = Date()
            let sinceLastUpdate = now.timeIntervalSince(lastUpdate ?? now)

            if sinceLastUpdate > updateInterval {
                updatePrices()
            } else {
                tick()
            }
        }
    }
    
    init() {
        startUpdateTimer()
    }
}

