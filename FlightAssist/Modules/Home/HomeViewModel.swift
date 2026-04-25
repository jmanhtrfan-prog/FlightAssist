//
//  HomeViewModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//import Foundation

import SwiftUI
import CloudKit

final class HomeViewModel: ObservableObject {
    @Published var boardingPassInfo: BoardingPassInfo? = nil
    @Published var recentServices: [String] = []
    @Published var scannerError: String? = nil
    @Published var isLoadingTicket: Bool = false

    private let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase

    init() {
        loadRecentServices()
        loadSavedBoardingPass()
    }

    func handleScannedValue(_ value: String) {
        fetchTicketFromCloudKit()
    }

    func fetchTicketFromCloudKit() {
        guard let userRecord = AppState.shared.currentUser else {
            self.scannerError = "User not logged in"
            return
        }

        let userID = userRecord.recordID.recordName
        print("🚀 fetchTicketFromCloudKit — userID = \(userID)")

        isLoadingTicket = true

        Task { @MainActor in
            do {
                // ١. جيب TicketScan
                let scanPredicate = NSPredicate(format: "user_id == %@", userID)
                let scanQuery = CKQuery(recordType: "TicketScan", predicate: scanPredicate)
                let scanResult = try await db.records(matching: scanQuery)

                guard let scanRecord = try scanResult.matchResults.first?.1.get() else {
                    self.scannerError = "No ticket found for this user"
                    self.isLoadingTicket = false
                    return
                }

                let ticketRecordName = scanRecord["ticket_id"] as? String ?? ""
                print("🎫 ticketRecordName = \(ticketRecordName)")

                // ٢. جيب Ticket
                let ticketRecord = try await db.record(for: CKRecord.ID(recordName: ticketRecordName))

                let seatID   = ticketRecord["seat_id1"]  as? String ?? ""
                let flightID = ticketRecord["flight_id"] as? String ?? ""

                // ٣. جيب Seat
                let seatRecord = try await db.record(for: CKRecord.ID(recordName: seatID))
                let seatNumber = seatRecord["seat_number"] as? String ?? "-"
                print("🪑 seatNumber = \(seatNumber)")

                // ٤. جيب Flight
                let flightRecord = try await db.record(for: CKRecord.ID(recordName: flightID))
                let flightNumber = flightRecord["flight_number"] as? String ?? "-"
                let origin       = flightRecord["origin"]        as? String ?? "-"
                let destination  = flightRecord["destination"]   as? String ?? "-"
                print("✈️ \(flightNumber) \(origin)→\(destination)")

                // ٥. بناء BoardingPassInfo مع gate و boarding ثابتة
                let info = BoardingPassInfo(
                    fullName: AppState.shared.currentUserName,
                    flightNumber: flightNumber,
                    from: origin,
                    to: destination,
                    gate: "5",
                    seat: seatNumber,
                    boardingTime: "21:30"
                )

                AppState.shared.currentUserSeat = seatNumber
                self.boardingPassInfo = info
                self.isLoadingTicket = false

                if let encoded = try? JSONEncoder().encode(info) {
                    UserDefaults.standard.set(encoded, forKey: "savedBoardingPass")
                }

            } catch {
                print("❌ Error: \(error.localizedDescription)")
                self.scannerError = error.localizedDescription
                self.isLoadingTicket = false
            }
        }
    }

    func saveRecentService(_ service: String) {
        if !recentServices.contains(service) {
            recentServices.append(service)
            UserDefaults.standard.set(recentServices.joined(separator: ","), forKey: "recentServicesStorage")
        }
    }

    func clearBoardingPass() {
        boardingPassInfo = nil
        UserDefaults.standard.removeObject(forKey: "savedBoardingPass")
    }

    func extract(pattern: String, from text: String) -> String? {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)),
               match.numberOfRanges > 1 {
                return nsText.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private func loadRecentServices() {
        if let saved = UserDefaults.standard.string(forKey: "recentServicesStorage") {
            recentServices = saved.components(separatedBy: ",")
        }
    }

    private func loadSavedBoardingPass() {
        if let data = UserDefaults.standard.data(forKey: "savedBoardingPass"),
           let info = try? JSONDecoder().decode(BoardingPassInfo.self, from: data) {
            boardingPassInfo = info
        }
    }
}
