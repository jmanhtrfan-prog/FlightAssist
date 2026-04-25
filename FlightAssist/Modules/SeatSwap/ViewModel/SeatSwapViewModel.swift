//
//  SeatSwapViewModel.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI
import CloudKit

@MainActor
final class SeatSelectionViewModel: ObservableObject {

    // يجي تلقائي من AppState بعد السكان
    var currentUserSeat: String {
        AppState.shared.currentUserSeat
    }

    @Published var leftSeats:   [[Seat]]
    @Published var middleSeats: [[Seat]]
    @Published var rightSeats:  [[Seat]]
    @Published var isSendingRequest = false
    @Published var requestSent = false
    @Published var errorMessage: String? = nil

    private let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase

    init() {
        leftSeats = Self.make(startRow: 14, cols: ["A","B"], statuses: [
            [.male,        .available],
            [.available,   .male],
            [.male,        .male],
            [.available,   .unavailable],
            [.female,      .unavailable],
            [.unavailable, .male],
            [.male,        .available],
            [.available,   .female],
            [.male,        .male],
        ])
        middleSeats = Self.make(startRow: 14, cols: ["C","D"], statuses: [
            [.available,   .male],
            [.male,        .female],
            [.unavailable, .available],
            [.available,   .male],
            [.female,      .available],   // 18C ← ليلى
            [.available,   .male],
            [.male,        .unavailable],
            [.available,   .available],
            [.unavailable, .male],
        ])
        rightSeats = Self.make(startRow: 14, cols: ["E","F"], statuses: [
            [.available,   .male],
            [.male,        .available],
            [.female,      .male],
            [.female,      .available],   // 17E ← تهاني
            [.available,   .male],
            [.male,        .female],
            [.available,   .available],
            [.male,        .unavailable],
            [.available,   .male],
        ])
    }

    // MARK: - Computed

    var selectedSeats: [Seat] {
        (leftSeats + middleSeats + rightSeats).flatMap { $0 }.filter { $0.isSelected }
    }
    var selectedCount: Int { selectedSeats.count }
    var canConfirm:    Bool { selectedCount > 0 }

    // MARK: - Toggle

    func toggleLeft(row: Int, col: Int)   { toggle(&leftSeats,   row: row, col: col) }
    func toggleMiddle(row: Int, col: Int) { toggle(&middleSeats, row: row, col: col) }
    func toggleRight(row: Int, col: Int)  { toggle(&rightSeats,  row: row, col: col) }

    private func toggle(_ s: inout [[Seat]], row: Int, col: Int) {
        let label = s[row][col].label
        guard label != currentUserSeat else { return }
        guard s[row][col].status != .unavailable else { return }
        clearAllSelections()
        s[row][col].isSelected = true
    }

    private func clearAllSelections() {
        for r in leftSeats.indices   { for c in leftSeats[r].indices   { leftSeats[r][c].isSelected   = false } }
        for r in middleSeats.indices { for c in middleSeats[r].indices { middleSeats[r][c].isSelected = false } }
        for r in rightSeats.indices  { for c in rightSeats[r].indices  { rightSeats[r][c].isSelected  = false } }
    }

    // MARK: - Seat Swap Request → CloudKit

    func confirmSelection() {
        guard let targetSeat = selectedSeats.first else { return }
        guard let userRecord = AppState.shared.currentUser else { return }

        isSendingRequest = true

        Task {
            do {
                // جيب الـ receiver عن طريق seat_number
                let seatPredicate = NSPredicate(format: "seat_number == %@", targetSeat.label)
                let seatQuery = CKQuery(recordType: "Seat", predicate: seatPredicate)
                let seatResult = try await db.records(matching: seatQuery)

                guard let targetSeatRecord = try seatResult.matchResults.first?.1.get() else {
                    self.errorMessage = "Target seat not found"
                    self.isSendingRequest = false
                    return
                }

                // جيب الـ Ticket حق المقعد المستهدف عشان نعرف الـ receiver
                let targetSeatID = targetSeatRecord.recordID.recordName
                let ticketPredicate = NSPredicate(format: "seat_id1 == %@", targetSeatID)
                let ticketQuery = CKQuery(recordType: "Ticket", predicate: ticketPredicate)
                let ticketResult = try await db.records(matching: ticketQuery)

                guard let targetTicket = try ticketResult.matchResults.first?.1.get() else {
                    self.errorMessage = "No ticket for target seat"
                    self.isSendingRequest = false
                    return
                }

                // جيب الـ TicketScan حق المستهدف عشان نعرف user_id
                let targetTicketID = targetTicket["ticket_id"] as? String ?? ""
                let scanPredicate = NSPredicate(format: "ticket_id == %@", targetTicketID)
                let scanQuery = CKQuery(recordType: "TicketScan", predicate: scanPredicate)
                let scanResult = try await db.records(matching: scanQuery)

                guard let targetScan = try scanResult.matchResults.first?.1.get() else {
                    self.errorMessage = "Receiver not found"
                    self.isSendingRequest = false
                    return
                }

                let receiverID = targetScan["user_id"] as? String ?? ""
                let senderID   = userRecord.recordID.recordName

                // سوّ SeatSwapRequest record
                let swapRecord = CKRecord(recordType: "SeatSwapRequest")
                swapRecord["request_id"]  = UUID().uuidString
                swapRecord["sender_id"]   = senderID
                swapRecord["receiver_id"] = receiverID
                swapRecord["from_seat_id"] = currentUserSeat
                swapRecord["to_seat_id"]   = targetSeat.label
                swapRecord["flight_id"]    = targetTicket["flight_id"] as? String ?? ""
                swapRecord["status"]       = "pending"

                try await db.save(swapRecord)

                // TODO: إرسال Push Notification للـ receiver هنا

                self.requestSent = true
                self.isSendingRequest = false

            } catch {
                self.errorMessage = error.localizedDescription
                self.isSendingRequest = false
            }
        }
    }

    // MARK: - Factory

    static func make(startRow: Int, cols: [String], statuses: [[SeatStatus]]) -> [[Seat]] {
        statuses.enumerated().map { ri, row in
            let rowNum = startRow + ri
            return row.enumerated().map { ci, st in
                let label = "\(rowNum)\(cols[ci])"
                return Seat(id: label, label: label, status: st)
            }
        }
    }
}
