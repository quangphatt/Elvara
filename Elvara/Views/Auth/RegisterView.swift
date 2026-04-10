//
//  RegisterView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = AuthViewModel.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var logoScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.primary, theme.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                        .shadow(color: theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                logoScale = 1.0
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Sign up to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        // Name
                        RegisterTextField(
                            icon: "person.fill",
                            label: "Full Name",
                            placeholder: "Enter your name",
                            text: $name,
                            theme: theme
                        )
                        
                        // Email
                        RegisterTextField(
                            icon: "envelope.fill",
                            label: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            theme: theme,
                            keyboardType: .emailAddress
                        )
                        
                        // Password
                        RegisterSecureField(
                            icon: "lock.fill",
                            label: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            showPassword: $showPassword,
                            theme: theme
                        )
                        
                        // Confirm Password
                        RegisterSecureField(
                            icon: "lock.fill",
                            label: "Confirm Password",
                            placeholder: "Confirm your password",
                            text: $confirmPassword,
                            showPassword: $showConfirmPassword,
                            theme: theme
                        )
                        
                        // Password match indicator
                        if !confirmPassword.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(passwordsMatch ? .green : .red)
                                
                                Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                    .font(.caption)
                                    .foregroundColor(passwordsMatch ? .green : .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Register Button
                    Button(action: {
                        Task {
                            await vm.register(email: email, password: password, name: name)
                        }
                    }) {
                        HStack {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [theme.primary, theme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(vm.isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    .padding(.horizontal, 24)
                    
                    // Terms
                    Text("By creating an account, you agree to our\n[Terms](https://example.com) and [Privacy Policy](https://example.com)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign In") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(theme.primary)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        passwordsMatch
    }
}

struct RegisterTextField: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    let theme: Theme
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(theme.primary)
                    .frame(width: 24)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct RegisterSecureField: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(theme.primary)
                    .frame(width: 24)
                
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
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
    }
}

#Preview {
    RegisterView()
}
