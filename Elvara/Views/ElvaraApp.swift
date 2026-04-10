//
//  ElvaraApp.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI
import Firebase

@main
struct ElvaraApp: App {
    @StateObject var themeManager = ThemeManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.theme, themeManager.currentTheme)
        }
    }
}
