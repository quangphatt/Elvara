//
//  WalletFormView.swift
//  Elvara
//
//  Created by Quang Phat on 13/4/26.
//

import SwiftUI

enum WalletFormMode {
    case create
    case edit(Wallet)
    var title: String {
        switch self {
        case .create: return "New Wallet"
        case .edit: return "Edit Wallet"
        }
    }
    var submitTitle: String {
        switch self {
        case .create: return "Create Wallet"
        case .edit: return "Save Changes"
        }
    }
}

struct WalletFormView: View {
    @Environment(\.dismiss) private var dismiss
        @Environment(\.theme) private var theme
        @ObservedObject var authVM = AuthViewModel.shared
        @ObservedObject var walletVM: WalletViewModel
        let mode: WalletFormMode
        @State private var name: String
        @State private var balanceText: String
        @State private var currency: String
        @State private var type: WalletType
        @State private var isSubmitting = false
        init(mode: WalletFormMode, walletVM: WalletViewModel) {
            self.mode = mode
            self.walletVM = walletVM
            switch mode {
            case .create:
                _name = State(initialValue: "")
                _balanceText = State(initialValue: "")
                _currency = State(initialValue: "VND")
                _type = State(initialValue: .cash)
            case .edit(let wallet):
                _name = State(initialValue: wallet.name)
                _balanceText = State(initialValue: String(format: "%.2f", wallet.balance))
                _currency = State(initialValue: wallet.currency)
                _type = State(initialValue: wallet.type)
            }
        }
        var body: some View {
            NavigationStack {
                Form {
                    Section("Wallet info") {
                        TextField("Name", text: $name)
                        TextField("Balance", text: $balanceText)
                            .keyboardType(.decimalPad)
                        TextField("Currency", text: $currency)
                            .textInputAutocapitalization(.characters)
                        Picker("Type", selection: $type) {
                            Text("Cash").tag(WalletType.cash)
                            Text("Bank").tag(WalletType.bank)
                            Text("E-Wallet").tag(WalletType.eWallet)
                        }
                        .pickerStyle(.segmented)
                    }
                    Section {
                        Button(action: submit) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(mode.submitTitle)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [theme.primary, theme.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                        }
                        .disabled(!isFormValid || isSubmitting)
                    }
                }
                .navigationTitle(mode.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
        private var isFormValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && parsedBalance >= 0
            && !currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        private var parsedBalance: Double {
            let normalized = balanceText.replacingOccurrences(of: ",", with: ".")
            return Double(normalized) ?? -1
        }
        private func submit() {
            guard let userId = authVM.user?.id else { return }
            isSubmitting = true
            Task {
                switch mode {
                case .create:
                    await walletVM.createWallet(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        balance: parsedBalance,
                        currency: currency.trimmingCharacters(in: .whitespacesAndNewlines),
                        type: type,
                        userId: userId
                    )
                case .edit(let wallet):
                    await walletVM.updateWallet(
                        wallet: wallet,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        balance: parsedBalance,
                        currency: currency.trimmingCharacters(in: .whitespacesAndNewlines),
                        type: type
                    )
                }
                isSubmitting = false
                dismiss()
            }
        }
}

//#Preview {
//    WalletFormView(mode: .create)
//}
