//
//  LoginView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.theme) var theme
    @StateObject var vm = AuthViewModel.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Header
                    VStack(spacing: 12) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Handle forgot password
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await vm.login(email: email, password: password)
                        }
                    }) {
                        HStack {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [theme.primary, theme.secondary],  // Dùng theme colors
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(vm.isLoading || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    
                    // Divider
//                    HStack {
//                        Rectangle()
//                            .fill(Color.secondary.opacity(0.3))
//                            .frame(height: 1)
//                        
//                        Text("OR")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal, 8)
//                        
//                        Rectangle()
//                            .fill(Color.secondary.opacity(0.3))
//                            .frame(height: 1)
//                    }
//                    .padding(.horizontal, 24)
                    
//                    // Social Login Buttons
//                    VStack(spacing: 12) {
//                        SocialLoginButton(
//                            icon: "apple.logo",
//                            title: "Continue with Apple",
//                            backgroundColor: .black
//                        )
//                        
//                        SocialLoginButton(
//                            icon: "g.circle.fill",
//                            title: "Continue with Google",
//                            backgroundColor: .white,
//                            foregroundColor: .black,
//                            hasBorder: true
//                        )
//                    }
//                    .padding(.horizontal, 24)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(theme.primary)
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    var backgroundColor: Color = .white
    var foregroundColor: Color = .white
    var hasBorder: Bool = false
    
    var body: some View {
        Button(action: {
            // Handle social login
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: hasBorder ? 1 : 0)
            )
        }
    }
}

#Preview {
    LoginView()
}
