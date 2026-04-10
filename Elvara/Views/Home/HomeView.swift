//
//  HomeView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = AuthViewModel.shared
    
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Avatar
                if let avatarURL = vm.user?.avatar {
                    AsyncImage(url: URL(string: avatarURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100)
                }
                
                // Name
                Text(vm.user?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Email
                Text(vm.user?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Phone
                if let phone = vm.user?.phoneNumber, !phone.isEmpty {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text(phone)
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
            }
            .padding()
            
            VStack(spacing: 12) {
                NavigationLink(destination: CategoryPickerView(type: .expense, selectedCategory: $selectedCategory)) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                        Text("Expense Categories")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: CategoryPickerView(type: .income, selectedCategory: $selectedCategory)) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Income Categories")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Logout Button
            Button(action: {
                vm.logout()
            }) {
                Text("Logout")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
}
