//
//  WalletView.swift
//  Elvara
//
//  Created by Quang Phat on 13/4/26.
//

import SwiftUI

struct WalletView: View {
    @ObservedObject private var authVM = AuthViewModel.shared
    @StateObject private var walletVM = WalletViewModel()
    @State private var showingCreateForm = false
    @State private var editingWallet: Wallet?
    @State private var walletToDelete: Wallet?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Wallets")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button {
                        showingCreateForm = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .frame(width: 40, height: 40)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Group {
                    if walletVM.isLoading {
                        ProgressView("Loading wallets...")
                    } else if walletVM.wallets.isEmpty {
                        ContentUnavailableView(
                            "No Wallets",
                            systemImage: "wallet.pass",
                            description: Text("Tap + to create your first wallet")
                        )
                    } else {
                        List {
                            ForEach(walletVM.wallets) { wallet in
                                walletRow(wallet)
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            editingWallet = wallet
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            walletToDelete = wallet
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .task {
                await loadWalletsIfPossible()
            }
            .sheet(isPresented: $showingCreateForm) {
                WalletFormView(mode: .create, walletVM: walletVM)
            }
            .sheet(item: $editingWallet) { wallet in
                WalletFormView(mode: .edit(wallet), walletVM: walletVM)
            }
            .alert("Delete wallet?", isPresented: .constant(walletToDelete != nil), actions: {
                Button("Cancel", role: .cancel) {
                    walletToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    guard let wallet = walletToDelete else { return }
                    Task {
                        await walletVM.deleteWallet(wallet)
                        walletToDelete = nil
                    }
                }
            }, message: {
                Text("This action cannot be undone.")
            })
        }
    }
    
    @ViewBuilder
    private func walletRow(_ wallet: Wallet) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon(for: wallet.type))
                .font(.title3)
                .frame(width: 34, height: 34)
                .foregroundStyle(.white)
                .background(Color.accentColor)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.name)
                    .font(.headline)
                Text(wallet.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(wallet.balance, specifier: "%.2f") \(wallet.currency)")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 6)
    }
    
    private func icon(for type: WalletType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bank: return "building.columns"
        case .eWallet: return "iphone"
        }
    }
    
    private func loadWalletsIfPossible() async {
        guard let userId = authVM.user?.id else { return }
        await walletVM.loadWallets(for: userId)
    }
}

#Preview {
    WalletView()
}
