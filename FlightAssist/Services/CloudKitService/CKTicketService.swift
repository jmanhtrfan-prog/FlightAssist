//
//  CKTicketService.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import Foundation
import SwiftUI

final class TicketScannerViewModel: ObservableObject {
    @Published var ticketInfo: TicketInfo? = nil
    @Published var recentServices: [String] = []
    @Published var scannerError: String? = nil

    func handleScannedValue(_ value: String) {

        print("TEXT >>> \(value)") // 🔥 مهم

        let text = value.uppercased()

        let airports = extractAll(pattern: #"\b[A-Z]{3}\b"#, from: text)
        let seat = extract(pattern: #"\b\d{1,2}[A-Z]\b"#, from: text)
        let flight = extract(pattern: #"\b[A-Z]{2}\d{2,4}\b"#, from: text)
        let time = extract(pattern: #"\d{1,2}:\d{2}"#, from: text)

        let info = TicketInfo(
            flightNumber: flight ?? "Not found",
            from: airports.count > 0 ? airports[0] : "Not found",
            to: airports.count > 1 ? airports[1] : "Not found",
            date: "-",
            time: time ?? "Not found",
            seat: seat ?? "Not found",
            gate: "-"
        )

        DispatchQueue.main.async {
            self.ticketInfo = info

            if self.recentServices.isEmpty {
                self.recentServices = ["Find my seat", "Change seats"]
            }
        }
    }

    // helpers
    func extract(pattern: String, from text: String) -> String? {
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let ns = text as NSString
            if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)) {
                return ns.substring(with: match.range)
            }
        }
        return nil
    }

    func extractAll(pattern: String, from text: String) -> [String] {
        var results: [String] = []
        let regex = try? NSRegularExpression(pattern: pattern)
        let ns = text as NSString

        regex?.enumerateMatches(in: text, range: NSRange(location: 0, length: ns.length)) { match, _, _ in
            if let match = match {
                results.append(ns.substring(with: match.range))
            }
        }
        return results
    }
}
