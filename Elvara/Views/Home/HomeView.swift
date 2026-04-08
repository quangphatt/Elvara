//
//  HomeView.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = AuthViewModel.shared
    
    var body: some View {
        Button("Logout") {
            Task {
                vm.logout()
            }
        }
    }
}

#Preview {
    HomeView()
}
