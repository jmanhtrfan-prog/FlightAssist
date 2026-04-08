//
//  BoardingPassInfo.swift.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import Foundation

struct BoardingPassInfo: Identifiable {
    let id = UUID()
    let fullName: String
    let flightNumber: String
    let from: String
    let to: String
    let gate: String
    let seat: String
    let boardingTime: String
}
