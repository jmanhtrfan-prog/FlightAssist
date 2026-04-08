//
//  TicketScannerViewModel.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import Foundation
import CloudKit

@MainActor
class TicketScannerViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase
    
    // استخراج البيانات من النص
    func parseAndSave(scannedText: String, userID: String) {
        let ticket = extractTicketInfo(from: scannedText)
        Task {
            await saveToCloudKit(ticket: ticket, userID: userID)
        }
    }
    
    private func extractTicketInfo(from text: String) -> TicketInfo {
        let lines = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var flightNumber = ""
        var from = ""
        var to = ""
        var date = ""
        var time = ""
        var seat = ""
        var gate = ""
        var terminal = ""
        
        for (index, line) in lines.enumerated() {
            
            // رقم الرحلة — مثال: SV123 أو 8N64BX
            if line.range(of: #"^[A-Z]{2}\d{3,4}$"#, options: .regularExpression) != nil {
                flightNumber = line
            }
            
            // PNR — مثال: 8N64BX
            if line.contains("PNR") || line.range(of: #"^[A-Z0-9]{6}$"#, options: .regularExpression) != nil {
                if index + 1 < lines.count {
                    flightNumber = lines[index + 1]
                }
            }
            
            // الوقت — مثال: 18:10
            if line.range(of: #"^\d{2}:\d{2}$"#, options: .regularExpression) != nil {
                time = line
            }
            
            // التاريخ — مثال: 27 January 2026
            if line.range(of: #"\d{1,2}\s+\w+\s+\d{4}"#, options: .regularExpression) != nil {
                date = line
            }
            
            // المقعد — مثال: 12A أو 34B
            if line.range(of: #"^\d{1,3}[A-F]$"#, options: .regularExpression) != nil {
                seat = line
            }
            
            // البوابة
            if line.lowercased().contains("gate") {
                gate = line.replacingOccurrences(of: "Gate", with: "")
                    .replacingOccurrences(of: "gate", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
            
            // التيرمينال
            if line.lowercased().contains("terminal") {
                terminal = line
            }
            
            // من وين — كود المطار 3 حروف
            if line.range(of: #"^[A-Z]{3}$"#, options: .regularExpression) != nil {
                if from.isEmpty {
                    from = line
                } else if to.isEmpty {
                    to = line
                }
            }
            
            // Riyadh RUH — المدينة + الكود
            if line.contains("RUH") || line.contains("Riyadh") { to = "RUH" }
            if line.contains("JED") || line.contains("Jeddah") { from = "JED" }
        }
        
        return TicketInfo(
            flightNumber: flightNumber,
            from: from,
            to: to,
            date: date,
            time: time,
            seat: seat,
            gate: gate.isEmpty ? terminal : gate
        )
    }
    
    private func saveToCloudKit(ticket: TicketInfo, userID: String) async {
        isLoading = true
        
        do {
            let record = CKRecord(recordType: "Ticket")
            record["ticket_id"] = UUID().uuidString
            record["flight_id"] = ticket.flightNumber
            record["seat_id1"] = ticket.seat
            record["booking_id"] = userID
            
            // حفظ الرحلة
            let flightRecord = CKRecord(recordType: "Flight")
            flightRecord["flight_number"] = ticket.flightNumber
            flightRecord["origin"] = ticket.from
            flightRecord["destination"] = ticket.to
            flightRecord["date"] = ticket.date + " " + ticket.time
            
            try await db.save(record)
            try await db.save(flightRecord)
            
            isSaved = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
