//
//  ThemeManager.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import SwiftUI
import Combine

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme = .default
    
    private init() {}
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
}

struct Theme {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let text: Color
    
    // Predefined Themes
    static let `default` = Theme(
        primary: Color(hex: "#007AFF"),
        secondary: Color(hex: "#5856D6"),
        accent: Color(hex: "#FF9500"),
        background: Color(.systemBackground),
        text: Color.primary
    )
    
    static let dark = Theme(
        primary: Color(hex: "#0A84FF"),
        secondary: Color(hex: "#5E5CE6"),
        accent: Color(hex: "#FF9F0A"),
        background: Color.black,
        text: Color.white
    )
    
    static let purple = Theme(
        primary: Color(hex: "#8B5CF6"),
        secondary: Color(hex: "#A78BFA"),
        accent: Color(hex: "#C084FC"),
        background: Color(.systemBackground),
        text: Color.primary
    )
}

// Environment Key
struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .default
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
