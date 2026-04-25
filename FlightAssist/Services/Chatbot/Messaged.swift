//
//  Untitled.swift
//  FlightAssist
//
//  Created by Jumana on 08/11/1447 AH.
//

import Foundation

struct Message: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
}
