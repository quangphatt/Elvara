//
//  TransactionFormMode.swift
//  Elvara
//
//  Created by Quang Phat on 16/4/26.
//

import SwiftUI

enum TransactionFormMode {
    case create
    case edit(Transaction)

    var title: String {
        switch self {
        case .create: return "New Transaction"
        case .edit: return "Edit Transaction"
        }
    }

    var submitTitle: String {
        switch self {
        case .create: return "Create"
        case .edit: return "Save Changes"
        }
    }
}

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authVM = AuthViewModel.shared
    @ObservedObject var vm: TransactionViewModel
    let mode: TransactionFormMode

    @State private var title: String
    @State private var amountText: String
    @State private var type: TransactionType
    @State private var date: Date
    @State private var note: String
    @State private var status: TransactionStatus

    @State private var walletId: String
    @State private var toWalletId: String
    @State private var categoryId: String

    @State private var isSubmitting = false

    init(mode: TransactionFormMode, vm: TransactionViewModel) {
        self.mode = mode
        self.vm = vm

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _amountText = State(initialValue: "")
            _type = State(initialValue: .expense)
            _date = State(initialValue: Date())
            _note = State(initialValue: "")
            _status = State(initialValue: .completed)
            _walletId = State(initialValue: "")
            _toWalletId = State(initialValue: "")
            _categoryId = State(initialValue: "")
        case .edit(let tx):
            _title = State(initialValue: tx.title)
            _amountText = State(initialValue: String(format: "%.2f", tx.amount))
            _type = State(initialValue: tx.type)
            _date = State(initialValue: tx.date)
            _note = State(initialValue: tx.note ?? "")
            _status = State(initialValue: tx.status)
            _walletId = State(initialValue: tx.walletId)
            _toWalletId = State(initialValue: tx.toWalletId ?? "")
            _categoryId = State(initialValue: tx.categoryId ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Title", text: $title)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])

                    Picker("Status", selection: $status) {
                        ForEach(TransactionStatus.allCases, id: \.self) { item in
                            Text(item.rawValue.capitalized).tag(item)
                        }
                    }
                }

                Section("Wallet") {
                    Picker("Wallet", selection: $walletId) {
                        Text("Select wallet").tag("")
                        ForEach(vm.wallets, id: \.id) { wallet in
                            Text(wallet.name).tag(wallet.id ?? "")
                        }
                    }

                    if type == .transfer {
                        Picker("To Wallet", selection: $toWalletId) {
                            Text("Select target wallet").tag("")
                            ForEach(vm.wallets.filter { $0.id != walletId }, id: \.id) { wallet in
                                Text(wallet.name).tag(wallet.id ?? "")
                            }
                        }
                    }
                }

                if type != .transfer {
                    Section("Category") {
                        Picker("Category", selection: $categoryId) {
                            Text("Select category").tag("")
                            ForEach(filteredCategories, id: \.id) { category in
                                Text(category.name).tag(category.id ?? "")
                            }
                        }
                    }
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button(action: submit) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text(mode.submitTitle).fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
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
            .onAppear {
                if walletId.isEmpty, let first = vm.wallets.first?.id {
                    walletId = first
                }
            }
            .onChange(of: type) { _, newType in
                if newType == .transfer {
                    categoryId = ""
                } else if categoryId.isEmpty, let firstCategory = filteredCategories.first?.id {
                    categoryId = firstCategory
                }
            }
        }
    }

    private var parsedAmount: Double {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        return Double(normalized) ?? -1
    }

    private var filteredCategories: [Category] {
        vm.categories.filter { $0.type == type }
    }

    private var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAmount = parsedAmount > 0
        let hasWallet = !walletId.isEmpty
        let hasCategoryIfNeeded = type == .transfer || !categoryId.isEmpty
        let hasToWalletIfTransfer = type != .transfer || (!toWalletId.isEmpty && toWalletId != walletId)

        return hasTitle && hasAmount && hasWallet && hasCategoryIfNeeded && hasToWalletIfTransfer
    }

    private func submit() {
        guard let userId = authVM.user?.id else { return }

        isSubmitting = true

        Task {
            let tx = buildTransaction(userId: userId)
            switch mode {
            case .create:
                await vm.createTransaction(tx)
            case .edit:
                await vm.updateTransaction(tx)
            }
            isSubmitting = false
            dismiss()
        }
    }

    private func buildTransaction(userId: String) -> Transaction {
        let existingId: String?
        let createdAt: Date?

        switch mode {
        case .create:
            existingId = nil
            createdAt = Date()
        case .edit(let old):
            existingId = old.id
            createdAt = old.createdAt
        }

        return Transaction(
            id: existingId,
            userId: userId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: parsedAmount,
            type: type,
            walletId: walletId,
            toWalletId: type == .transfer ? toWalletId : nil,
            categoryId: type == .transfer ? nil : categoryId,
            date: date,
            status: status,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: createdAt,
            updatedAt: nil
        )
    }
}
