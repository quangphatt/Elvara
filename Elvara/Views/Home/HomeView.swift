//
//  HomeView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "house") {
                Text("Dashboard")
            }
            Tab("Transaction", systemImage: "arrow.left.arrow.right.circle.fill") {
                Text("Transaction")
            }
            Tab("Wallet", systemImage: "wallet.pass.fill") {
                WalletView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileView()
            }
        }
    }
}

#Preview {
    HomeView()
}
