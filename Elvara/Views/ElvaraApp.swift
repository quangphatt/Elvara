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
    @StateObject var authVM = AuthViewModel.shared
    @StateObject var themeManager = ThemeManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .onAppear {
                authVM.checkSession()
            }
            .environment(\.theme, themeManager.currentTheme)
        }
    }
}
