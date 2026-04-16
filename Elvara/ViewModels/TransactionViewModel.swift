//
//  TransactionDaySection.swift
//  Elvara
//
//  Created by Quang Phat on 16/4/26.
//

import Foundation
import Combine

struct TransactionDaySection: Identifiable {
    let date: Date
    let transactions: [Transaction]

    var id: Date { date }

    var incomeTotal: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var expenseTotal: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
}

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var sections: [TransactionDaySection] = []
    @Published var selectedMonth: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var wallets: [Wallet] = []
    @Published var categories: [Category] = []

    private let manager = TransactionManager.shared
    private let walletManager = WalletManager.shared
    private let categoryManager = CategoryManager.shared
    private var currentUserId: String?

    var monthIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var monthExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var monthBalance: Double {
        monthIncome - monthExpense
    }

    func loadInitialData(for userId: String) async {
        currentUserId = userId
        isLoading = true
        errorMessage = nil

        async let loadedWallets = walletManager.getWallets(for: userId)
        async let loadedCategories = categoryManager.getCategories(for: userId)
        async let loadedTransactions = manager.getTransactions(for: userId, month: selectedMonth)

        wallets = await loadedWallets
        categories = await loadedCategories
        transactions = await loadedTransactions
        rebuildSections()

        isLoading = false
    }

    func reloadMonth() async {
        guard let userId = currentUserId else { return }
        isLoading = true
        transactions = await manager.getTransactions(for: userId, month: selectedMonth)
        rebuildSections()
        isLoading = false
    }

    func moveMonth(by offset: Int) async {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: selectedMonth) else { return }
        selectedMonth = newMonth
        await reloadMonth()
    }

    func createTransaction(_ transaction: Transaction) async {
        guard currentUserId != nil else { return }
        errorMessage = nil

        do {
            var newTx = transaction
            let newId = try await manager.createTransaction(newTx)
            newTx.id = newId
            transactions.insert(newTx, at: 0)
            rebuildSections()
        } catch {
            errorMessage = "Failed to create transaction: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }

    func updateTransaction(_ transaction: Transaction) async {
        errorMessage = nil
        do {
            try await manager.updateTransaction(transaction)
            if let idx = transactions.firstIndex(where: { $0.id == transaction.id }) {
                transactions[idx] = transaction
            }
            rebuildSections()
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }

    func deleteTransaction(_ transaction: Transaction) async {
        guard let id = transaction.id else { return }
        errorMessage = nil

        do {
            try await manager.deleteTransaction(id: id)
            transactions.removeAll { $0.id == id }
            rebuildSections()
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }

    func walletName(for walletId: String) -> String {
        wallets.first(where: { $0.id == walletId })?.name ?? "Unknown Wallet"
    }

    func categoryName(for categoryId: String?) -> String {
        guard let categoryId else { return "No Category" }
        return categories.first(where: { $0.id == categoryId })?.name ?? "No Category"
    }

    private func rebuildSections() {
        let grouped = Dictionary(grouping: transactions) { tx in
            Calendar.current.startOfDay(for: tx.date)
        }

        sections = grouped
            .map { TransactionDaySection(date: $0.key, transactions: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }
}
