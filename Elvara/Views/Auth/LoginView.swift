//
//  LoginView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm = AuthViewModel.shared
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button("Login") {
                Task {
                    await vm.login(email: email, password: password)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
