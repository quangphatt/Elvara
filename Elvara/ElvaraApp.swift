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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
