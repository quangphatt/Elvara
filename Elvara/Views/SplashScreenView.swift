//
//  SplashScreenView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.theme) var theme
    @StateObject var authVM = AuthViewModel.shared
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            Group {
                if authVM.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
        } else {
            ZStack {
                // Solid Background
                theme.primary
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Logo
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    // App Name
                    Text("Elvara")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.white)
                }
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        opacity = 1.0
                    }
                }
            }
            .onAppear {
                authVM.checkSession()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
