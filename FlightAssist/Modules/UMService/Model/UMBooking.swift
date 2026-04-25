//
//  UMBooking.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

//
//  UMModels.swift
//  FlightAssist
//
//  CloudKit models for UM Service
//

import Foundation
import CloudKit

// MARK: - UM Booking Model
struct UMBooking: Identifiable {
    let id: String
    var bookingReference: String
    var ticketNumber: String
    var flightNumber: String
    var travelDate: Date
    var childFullName: String
    var childID: String
    var parentFullName: String
    var parentID: String
    var confirmationChecked: Bool
    var status: UMBookingStatus
    var createdAt: Date
    var ticketID: String
    
    // CloudKit record
    var recordID: CKRecord.ID?
    
    enum UMBookingStatus: String, CaseIterable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    init(
        id: String = UUID().uuidString,
        bookingReference: String = "",
        ticketNumber: String = "",
        flightNumber: String = "",
        travelDate: Date = Date(),
        childFullName: String = "",
        childID: String = "",
        parentFullName: String = "",
        parentID: String = "",
        confirmationChecked: Bool = false,
        status: UMBookingStatus = .pending,
        createdAt: Date = Date(),
        ticketID: String = "",
        recordID: CKRecord.ID? = nil
    ) {
        self.id = id
        self.bookingReference = bookingReference
        self.ticketNumber = ticketNumber
        self.flightNumber = flightNumber
        self.travelDate = travelDate
        self.childFullName = childFullName
        self.childID = childID
        self.parentFullName = parentFullName
        self.parentID = parentID
        self.confirmationChecked = confirmationChecked
        self.status = status
        self.createdAt = createdAt
        self.ticketID = ticketID
        self.recordID = recordID
    }
    
    // Convert to CloudKit Record
    func toCKRecord() -> CKRecord {
        let record = recordID != nil ? CKRecord(recordType: "UMBooking", recordID: recordID!) : CKRecord(recordType: "UMBooking")
        
        record["bookingReference"] = bookingReference as CKRecordValue
        record["ticketNumber"] = ticketNumber as CKRecordValue
        record["flightNumber"] = flightNumber as CKRecordValue
        record["travelDate"] = travelDate as CKRecordValue
        record["childFullName"] = childFullName as CKRecordValue
        record["childID"] = childID as CKRecordValue
        record["parentFullName"] = parentFullName as CKRecordValue
        record["parentID"] = parentID as CKRecordValue
        record["confirmationChecked"] = confirmationChecked as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["ticketID"] = ticketID as CKRecordValue
        
        return record
    }
    
    // Convert from CloudKit Record
    static func fromCKRecord(_ record: CKRecord) -> UMBooking {
        return UMBooking(
            id: record.recordID.recordName,
            bookingReference: record["bookingReference"] as? String ?? "",
            ticketNumber: record["ticketNumber"] as? String ?? "",
            flightNumber: record["flightNumber"] as? String ?? "",
            travelDate: record["travelDate"] as? Date ?? Date(),
            childFullName: record["childFullName"] as? String ?? "",
            childID: record["childID"] as? String ?? "",
            parentFullName: record["parentFullName"] as? String ?? "",
            parentID: record["parentID"] as? String ?? "",
            confirmationChecked: record["confirmationChecked"] as? Bool ?? false,
            status: UMBookingStatus(rawValue: record["status"] as? String ?? "Pending") ?? .pending,
            createdAt: record["createdAt"] as? Date ?? Date(),
            ticketID: record["ticketID"] as? String ?? "",
            recordID: record.recordID
        )
    }
}

// MARK: - Ticket Model (from CloudKit)
struct Ticket: Identifiable {
    let id: String
    var bookingID: String
    var flightID: String
    var seatID: String
    var seatID1: String?
    var ticketID: String
    
    var recordID: CKRecord.ID?
    
    static func fromCKRecord(_ record: CKRecord) -> Ticket {
        return Ticket(
            id: record.recordID.recordName,
            bookingID: record["booking_id"] as? String ?? "",
            flightID: record["flight_id"] as? String ?? "",
            seatID: record["seat_id"] as? String ?? "",
            seatID1: record["seat_id1"] as? String,
            ticketID: record["ticket_id"] as? String ?? "",
            recordID: record.recordID
        )
    }
}
