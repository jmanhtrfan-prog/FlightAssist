//
//  Seat.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI

// MARK: - SeatStatus

enum SeatStatus {
    case available, female, male, unavailable

    var fillColor: Color {
        switch self {
        case .available:   return .white
        case .female:      return Color(hex: "#EF4E8A")
        case .male:        return Color(hex: "#6B52B8")
        case .unavailable: return Color(hex: "#C4C4C4")
        }
    }

    var strokeColor: Color {
        switch self {
        case .available:   return Color(hex: "#6B52B8").opacity(0.5)
        case .female:      return Color(hex: "#C4326A")
        case .male:        return Color(hex: "#4A3490")
        case .unavailable: return Color(hex: "#AAAAAA")
        }
    }

    var labelColor: Color {
        switch self {
        case .available:   return Color(hex: "#555555")
        case .unavailable: return Color(hex: "#999999")
        default:           return .white
        }
    }

    var isSelectable: Bool { self == .available }
}

// MARK: - Seat

struct Seat: Identifiable {
    let id: String
    let label: String
    var status: SeatStatus
    var isSelected: Bool = false
}
