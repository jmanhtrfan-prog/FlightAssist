//
//  AppColors.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI

struct AppColors {
    
    static let primary = Color(hex: "5B1E7A")
    static let secondary = Color(hex: "7A2FA3")
    static let darkPurple = Color(hex: "3E0F5A")
    static let cardPurple = Color(hex: "6D2C91")
    
    static let supervisorPurple = Color(hex: "6B2D79")
    static let supervisorPurpleLight = Color(hex: "7A2FA3")
    
    static let pendingColor = Color(hex: "FFC200").opacity(0.23)
    static let activeColor = Color(hex: "288EE7").opacity(0.29)
    
    static let white = Color.white
    static let black = Color.black
    static let gray = Color.gray
    
    static let textFieldBackground = Color.white
    static let background = Color(hex: "F4F2F6")
    static let emptyCard = Color(hex: "E9E7EC")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
