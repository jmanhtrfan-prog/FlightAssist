//
//  CKUMService.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

//
//  UMCloudKitService.swift
//  FlightAssist
//
//  CloudKit service for UM booking operations
//

import Foundation
import CloudKit

class UMCloudKitService {
    
    static let shared = UMCloudKitService()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    private init() {
        container = CKContainer.default()
        publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - Fetch Tickets
    
    /// Fetch all tickets from CloudKit
    func fetchTickets() async throws -> [Ticket] {
        let query = CKQuery(recordType: "Ticket", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var tickets: [Ticket] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                tickets.append(Ticket.fromCKRecord(record))
            case .failure(let error):
                print("Error fetching ticket: \(error)")
            }
        }
        
        return tickets
    }
    
    /// Fetch specific ticket by ticket ID
    func fetchTicket(byTicketID ticketID: String) async throws -> Ticket? {
        let predicate = NSPredicate(format: "ticket_id == %@", ticketID)
        let query = CKQuery(recordType: "Ticket", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        for (_, result) in results {
            switch result {
            case .success(let record):
                return Ticket.fromCKRecord(record)
            case .failure(let error):
                print("Error fetching ticket: \(error)")
            }
        }
        
        return nil
    }
    
    // MARK: - UM Booking Operations
    
    /// Save UM booking to CloudKit
    func saveUMBooking(_ booking: UMBooking) async throws -> UMBooking {
        let record = booking.toCKRecord()
        
        let savedRecord = try await publicDatabase.save(record)
        return UMBooking.fromCKRecord(savedRecord)
    }
    
    /// Fetch all UM bookings
    func fetchUMBookings() async throws -> [UMBooking] {
        let query = CKQuery(recordType: "UMBooking", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var bookings: [UMBooking] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                bookings.append(UMBooking.fromCKRecord(record))
            case .failure(let error):
                print("Error fetching UM booking: \(error)")
            }
        }
        
        return bookings
    }
    
    /// Fetch UM bookings by status
    func fetchUMBookings(status: UMBooking.UMBookingStatus) async throws -> [UMBooking] {
        let predicate = NSPredicate(format: "status == %@", status.rawValue)
        let query = CKQuery(recordType: "UMBooking", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var bookings: [UMBooking] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                bookings.append(UMBooking.fromCKRecord(record))
            case .failure(let error):
                print("Error fetching UM booking: \(error)")
            }
        }
        
        return bookings
    }
    
    /// Update UM booking status
    func updateBookingStatus(bookingID: CKRecord.ID, status: UMBooking.UMBookingStatus) async throws {
        let record = try await publicDatabase.record(for: bookingID)
        record["status"] = status.rawValue as CKRecordValue
        
        _ = try await publicDatabase.save(record)
    }
    
    /// Delete UM booking
    func deleteUMBooking(_ bookingID: CKRecord.ID) async throws {
        _ = try await publicDatabase.deleteRecord(withID: bookingID)
    }
}
