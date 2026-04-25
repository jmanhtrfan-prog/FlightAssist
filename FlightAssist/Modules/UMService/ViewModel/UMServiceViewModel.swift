//
//  UMServiceViewModel.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

//
//  UMBookingViewModel.swift
//  FlightAssist
//
//  ViewModel for UM booking flow
//

import Foundation
import SwiftUI

@MainActor
class UMBookingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Step 1: Booking Information
    @Published var bookingReference: String = ""
    @Published var ticketNumber: String = ""
    @Published var flightNumber: String = ""
    @Published var travelDate: Date = Date()
    
    // Step 2: Child Information
    @Published var childFullName: String = ""
    @Published var childID: String = ""
    
    // Step 3: Parent/Guardian Information
    @Published var parentFullName: String = ""
    @Published var parentID: String = ""
    @Published var flightNumberParent: String = ""
    @Published var confirmationChecked: Bool = false
    
    // UI State
    @Published var currentStep: BookingStep = .bookingInfo
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    @Published var bookingComplete: Bool = false
    
    // Data
    @Published var selectedTicket: Ticket?
    @Published var availableTickets: [Ticket] = []
    
    // Services
    private let cloudKitService = UMCloudKitService.shared
    
    // MARK: - Booking Steps
    enum BookingStep: Int, CaseIterable {
        case bookingInfo = 0
        case childInfo = 1
        case parentInfo = 2
        case liability = 3
        case confirmation = 4
        
        var title: String {
            switch self {
            case .bookingInfo: return "Booking Information"
            case .childInfo: return "Child Information"
            case .parentInfo: return "Parent / Legal Guardian Information"
            case .liability: return "Minor Travel"
            case .confirmation: return "Confirmation"
            }
        }
        
        var progressIndex: Int {
            return rawValue
        }
    }
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadTickets()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load available tickets from CloudKit
    func loadTickets() async {
        isLoading = true
        
        do {
            availableTickets = try await cloudKitService.fetchTickets()
        } catch {
            errorMessage = "Failed to load tickets: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Auto-fill booking info from ticket
    func autoFillFromTicket(_ ticketNumber: String) async {
        isLoading = true
        
        do {
            if let ticket = try await cloudKitService.fetchTicket(byTicketID: ticketNumber) {
                selectedTicket = ticket
                self.ticketNumber = ticket.ticketID
                // Note: You'll need to fetch flight details from your Flight record
                // For now, using ticket data
                self.bookingReference = ticket.bookingID
                
                // If you have flight info in ticket or need to fetch:
                // let flight = try await fetchFlight(ticket.flightID)
                // self.flightNumber = flight.flightNumber
            } else {
                errorMessage = "Ticket not found"
                showError = true
            }
        } catch {
            errorMessage = "Failed to fetch ticket: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Validate current step
    func validateCurrentStep() -> Bool {
        switch currentStep {
        case .bookingInfo:
            return !bookingReference.isEmpty &&
                   !ticketNumber.isEmpty &&
                   !flightNumber.isEmpty
            
        case .childInfo:
            return !childFullName.isEmpty &&
                   !childID.isEmpty
            
        case .parentInfo:
            return !parentFullName.isEmpty &&
                   !parentID.isEmpty &&
                   !flightNumberParent.isEmpty &&
                   confirmationChecked
            
        case .liability:
            return true // Terms acceptance happens in UI
            
        case .confirmation:
            return true
        }
    }
    
    /// Move to next step
    func continueToNextStep() {
        guard validateCurrentStep() else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        if let nextStep = BookingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        }
    }
    
    /// Move to previous step
    func goToPreviousStep() {
        if let previousStep = BookingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = previousStep
            }
        }
    }
    
    /// Submit UM booking
    func submitBooking() async {
        guard validateCurrentStep() else {
            errorMessage = "Please complete all required information"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let booking = UMBooking(
                bookingReference: bookingReference,
                ticketNumber: ticketNumber,
                flightNumber: flightNumber,
                travelDate: travelDate,
                childFullName: childFullName,
                childID: childID,
                parentFullName: parentFullName,
                parentID: parentID,
                confirmationChecked: confirmationChecked,
                status: .pending,
                ticketID: selectedTicket?.ticketID ?? ticketNumber
            )
            
            let savedBooking = try await cloudKitService.saveUMBooking(booking)
            
            // Success
            bookingComplete = true
            showSuccess = true
            
            // Move to confirmation step
            withAnimation {
                currentStep = .confirmation
            }
            
        } catch {
            errorMessage = "Failed to submit booking: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Reset booking
    func resetBooking() {
        bookingReference = ""
        ticketNumber = ""
        flightNumber = ""
        travelDate = Date()
        childFullName = ""
        childID = ""
        parentFullName = ""
        parentID = ""
        flightNumberParent = ""
        confirmationChecked = false
        currentStep = .bookingInfo
        selectedTicket = nil
        bookingComplete = false
    }
    
    // MARK: - Computed Properties
    
    var progressValue: Double {
        return Double(currentStep.rawValue) / Double(BookingStep.allCases.count - 2)
    }
    
    var canContinue: Bool {
        return validateCurrentStep() && !isLoading
    }
}
