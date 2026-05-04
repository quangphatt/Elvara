//
//  TransactionView.swift
//  Elvara
//
//  Created by Quang Phat on 16/4/26.
//

import SwiftUI

struct TransactionView: View {
    @ObservedObject private var authVM = AuthViewModel.shared
    @StateObject private var vm = TransactionViewModel()
    @State private var showingCreateForm = false
    @State private var editingTransaction: Transaction?
    @State private var transactionToDelete: Transaction?
    @State private var isShowingDeleteAlert = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Transaction")
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
                
                monthHeader
                monthSummary
                content
            }
            .task {
                guard let userId = authVM.user?.id else { return }
                await vm.loadInitialData(for: userId)
            }
            .sheet(isPresented: $showingCreateForm) {
                TransactionFormView(mode: .create, vm: vm)
            }
            .sheet(item: $editingTransaction) { tx in
                TransactionFormView(mode: .edit(tx), vm: vm)
            }
            .alert("Delete transaction?",
                isPresented: $isShowingDeleteAlert,
                actions: {
                    Button("Cancel", role: .cancel) {
                        transactionToDelete = nil
                    }
                    Button("Delete", role: .destructive) {
                        guard let tx = transactionToDelete else { return }
                        Task {
                            await vm.deleteTransaction(tx)
                            transactionToDelete = nil
                        }
                    }
                },
                message: {
                    Text("This action cannot be undone.")
                }
            )
        }
    }
    // MARK: - Top UI
    private var monthHeader: some View {
        HStack {
            Button {
                Task { await vm.moveMonth(by: -1) }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(vm.selectedMonth))
                .font(.headline)
            Spacer()
            Button {
                Task { await vm.moveMonth(by: 1) }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    private var monthSummary: some View {
        HStack(spacing: 12) {
            summaryCard(title: "Income", value: vm.monthIncome, color: .green)
            summaryCard(title: "Expense", value: vm.monthExpense, color: .red)
            summaryCard(title: "Balance", value: vm.monthBalance, color: .blue)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    private func summaryCard(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value, format: .number.precision(.fractionLength(0...2)))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        Group {
            if vm.isLoading {
                ProgressView("Loading transactions...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "tray",
                    description: Text("Tap + to create your first transaction")
                )
            } else {
                transactionsList
            }
        }
    }
    private var transactionsList: some View {
        List {
            ForEach(vm.sections) { section in
                TransactionDaySectionView(
                    section: section,
                    walletName: vm.walletName(for:),
                    categoryName: vm.categoryName(for:),
                    onEdit: { tx in editingTransaction = tx },
                    onDelete: { tx in
                        transactionToDelete = tx
                        isShowingDeleteAlert = true
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
    }
    // MARK: - Date formatting
    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    private func dayTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd/MM/yyyy"
        return formatter.string(from: date)
    }
    // MARK: - Subviews
    private struct TransactionDaySectionView: View {
        let section: TransactionDaySection
        let walletName: (String) -> String
        let categoryName: (String?) -> String
        let onEdit: (Transaction) -> Void
        let onDelete: (Transaction) -> Void
        var body: some View {
            Section(header: Text(dayTitle(section.date)).font(.subheadline.weight(.semibold))) {
                ForEach(section.transactions, id: \.self) { tx in
                    TransactionRowWithSwipe(
                        tx: tx,
                        walletName: walletName,
                        categoryName: categoryName,
                        onEdit: onEdit,
                        onDelete: onDelete
                    )
                }
            }
        }
        private func dayTitle(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd/MM/yyyy"
            return formatter.string(from: date)
        }
    }
    private struct TransactionRowWithSwipe: View {
        let tx: Transaction
        let walletName: (String) -> String
        let categoryName: (String?) -> String
        let onEdit: (Transaction) -> Void
        let onDelete: (Transaction) -> Void
        var body: some View {
            TransactionRowBase(tx: tx, walletName: walletName, categoryName: categoryName)
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        onEdit(tx)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete(tx)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
    private struct TransactionRowBase: View {
        let tx: Transaction
        let walletName: (String) -> String
        let categoryName: (String?) -> String
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon(for: tx.type))
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(tx.title)
                        .font(.headline)
                    switch tx.type {
                    case .transfer:
                        Text("\(walletName(tx.walletId)) -> \(walletName(tx.toWalletId ?? ""))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    case .income, .expense:
                        Text("\(categoryName(tx.categoryId)) • \(walletName(tx.walletId))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(signedAmountText(tx))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(amountColor(tx.type))
            }
            .padding(.vertical, 4)
        }
        private func icon(for type: TransactionType) -> String {
            switch type {
            case .income: return "arrow.down.circle.fill"
            case .expense: return "arrow.up.circle.fill"
            case .transfer: return "arrow.left.arrow.right.circle.fill"
            }
        }
        private func signedAmountText(_ tx: Transaction) -> String {
            let s = String(format: "%.2f", tx.amount)
            switch tx.type {
            case .income: return "+\(s)"
            case .expense: return "-\(s)"
            case .transfer: return s
            }
        }
        private func amountColor(_ type: TransactionType) -> Color {
            switch type {
            case .income: return .green
            case .expense: return .red
            case .transfer: return .primary
            }
        }
    }
}

#Preview {
    TransactionView()
}
