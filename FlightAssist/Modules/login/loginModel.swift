//
//  loginModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI

struct LoginModel {
    
    var username: String = ""
    var password: String = ""
    var showPassword: Bool = false
    
    static let primary = Color(hex: "5B1E7A")
    static let secondary = Color(hex: "7A2FA3")
    static let darkPurple = Color(hex: "3E0F5A")
    static let cardPurple = Color(hex: "6D2C91")
    
    static let white = Color.white
    static let black = Color.black
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
