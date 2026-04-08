//
//  HomeViewModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//
import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var boardingPassInfo: BoardingPassInfo?
    @Published var scannerError: String?

    @AppStorage("recentServicesStorage") var recentServicesStorage: String = ""

    var recentServices: [String] {
        recentServicesStorage
            .split(separator: ",")
            .map { String($0) }
    }

    func handleScannedValue(_ value: String) {
        let parts = value.components(separatedBy: "|")

        guard parts.count >= 7 else {
            scannerError = "Invalid ticket data"
            return
        }

        boardingPassInfo = BoardingPassInfo(
            fullName: parts[0],
            flightNumber: parts[1],
            from: parts[2],
            to: parts[3],
            gate: parts[4],
            seat: parts[5],
            boardingTime: parts[6]
        )
    }

    func saveRecentService(_ service: String) {
        var items = recentServices.filter { $0 != service }
        items.insert(service, at: 0)

        if items.count > 2 {
            items = Array(items.prefix(2))
        }

        recentServicesStorage = items.joined(separator: ",")
    }
}
