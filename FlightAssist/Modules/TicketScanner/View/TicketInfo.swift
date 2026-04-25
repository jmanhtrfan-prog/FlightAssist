//
//  TicketInfo.swift
//  FlightAssist
//
//  Created by Jumana on 21/10/1447 AH.
//
import Foundation

struct TicketInfo: Codable {
    var flightNumber: String
    var from: String
    var to: String
    var date: String
    var time: String
    var seat: String
    var gate: String
}
