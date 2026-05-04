//
//  CategoryPickerView.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.theme) var theme
    @StateObject var vm = CategoryViewModel()
    @ObservedObject var authVM = AuthViewModel.shared
    
    let type: TransactionType
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreateCategory = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(vm.categories) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    )
                    .onTapGesture {
                        selectedCategory = category
                        dismiss()
                    }
                }
                
                // Add Custom Category Button
                AddCategoryCard()
                    .onTapGesture {
                        showCreateCategory = true
                    }
            }
            .padding()
        }
        .navigationTitle("Select Category")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCategories()
        }
        .sheet(isPresented: $showCreateCategory) {
            CreateCategoryView(categoryVM: vm, type: type)
        }
        .onChange(of: showCreateCategory) { oldValue, newValue in
            if oldValue == true && newValue == false {
                Task {
                    await loadCategories()
                }
            }
        }
        
    }
    
    private func loadCategories() async {
        if let userId = authVM.user?.id {
            await vm.loadCategories(for: userId, type: type)
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(category.colorValue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.colorValue)
            }
            
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? category.colorValue.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? category.colorValue : Color.clear, lineWidth: 2)
        )
    }
}

struct AddCategoryCard: View {
    var body: some View {
        VStack(spacing: 8) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Text - Fixed height
            Text("Add New")
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(height: 32)  // Same height as CategoryCard
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    @Previewable @State var selectedCategory: Category? = nil
    CategoryPickerView(type: .income, selectedCategory: $selectedCategory)
}
