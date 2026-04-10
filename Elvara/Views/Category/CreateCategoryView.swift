//
//  CreateCategoryView.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import SwiftUI

struct CreateCategoryView: View {
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authVM = AuthViewModel.shared
    @ObservedObject var categoryVM: CategoryViewModel
    
    let type: TransactionType
    
    @State private var categoryName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#007AFF"
    @State private var isCreating = false
    
    // Predefined icons
    private let icons = [
        "star.fill", "heart.fill", "flame.fill", "bolt.fill",
        "leaf.fill", "drop.fill", "snowflake", "sun.max.fill",
        "moon.fill", "cloud.fill", "umbrella.fill", "wind",
        "cart.fill", "bag.fill", "creditcard.fill", "banknote",
        "gift.fill", "gamecontroller.fill", "music.note", "book.fill",
        "graduationcap.fill", "briefcase.fill", "house.fill", "car.fill",
        "airplane", "bicycle", "bus.fill", "tram.fill",
        "fork.knife", "cup.and.saucer.fill", "mug.fill", "wineglass.fill",
        "pill.fill", "cross.case.fill", "stethoscope", "bandage.fill"
    ]
    
    // Predefined colors
    private let colors = [
        "#007AFF", "#5856D6", "#AF52DE", "#FF2D55",
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#00C7BE", "#30B0C7", "#32ADE6", "#64D2FF",
        "#BF5AF2", "#FF6482", "#FF375F", "#FF453A",
        "#8E8E93", "#636366", "#48484A", "#3A3A3C"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview Card
                    VStack(spacing: 16) {
                        Text("Preview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: selectedColor).opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: selectedColor))
                                }
                                
                                Text(categoryName.isEmpty ? "Category Name" : categoryName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Category Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.headline)
                        
                        TextField("Enter category name", text: $categoryName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Icon Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Icon")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                IconButton(
                                    icon: icon,
                                    isSelected: selectedIcon == icon,
                                    color: Color(hex: selectedColor)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Color Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Color")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                ColorButton(
                                    color: color,
                                    isSelected: selectedColor == color
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Create Button
                    Button(action: {
                        createCategory()
                    }) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Category")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [theme.primary, theme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(categoryName.isEmpty || isCreating)
                    .opacity(categoryName.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.top)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createCategory() {
        guard let userId = authVM.user?.id else { return }
        
        isCreating = true
        Task {
            await categoryVM.createCategory(
                name: categoryName,
                icon: selectedIcon,
                type: type,
                color: selectedColor,
                userId: userId
            )
            isCreating = false
            dismiss()
        }
    }
}
// Icon Button Component
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? color.opacity(0.2) : Color(.systemGray6))
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? color : .secondary)
        }
        .overlay(
            Circle()
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
    }
}
// Color Button Component
struct ColorButton: View {
    let color: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 50, height: 50)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .overlay(
            Circle()
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
        )
        .shadow(color: isSelected ? Color(hex: color).opacity(0.5) : .clear, radius: 8, x: 0, y: 4)
    }
}
#Preview {
    @Previewable @State var vm = CategoryViewModel()
    
    CreateCategoryView(categoryVM: vm, type: .expense)
        .environment(\.theme, .default)
        .onAppear {
            AuthViewModel.shared.user = User(
                id: "preview_user",
                email: "preview@example.com",
                name: "Preview User"
            )
        }
}
