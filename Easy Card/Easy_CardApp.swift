//
//  Easy_CardApp.swift
//  Easy Card
//
//  Created by Fred Z on 2025-01-14.
//

import SwiftUI

@main
struct Easy_CardApp: App {
    @StateObject private var cardStore = CardStore()
    
    init() {
        // 确保 App Groups 已经设置
        setupAppGroups()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cardStore)
        }
    }
    
    private func setupAppGroups() {
        // 确保 UserDefaults 的 suite 存在
        if let userDefaults = UserDefaults(suiteName: "group.com.fredz6.Easy-Card") {
            if userDefaults.array(forKey: "recentCards") == nil {
                userDefaults.set([], forKey: "recentCards")
            }
        }
    }
}
