//
//  infostep.swift
//  FlightAssist
//
//  Created by Danyah ALbarqawi on 25/04/2026.
//

//
//  BookingInfoStepView.swift
//  FlightAssist
//
//  Step 1: Booking Information
//

import SwiftUI

struct BookingInfoStepView: View {
    @ObservedObject var viewModel: UMBookingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Booking Reference
            InputField(
                title: "Booking Reference",
                text: $viewModel.bookingReference,
                placeholder: ""
            )
            
            // Ticket Number
            InputField(
                title: "Ticket Number",
                text: $viewModel.ticketNumber,
                placeholder: ""
            )
            .onChange(of: viewModel.ticketNumber) { newValue in
                // Auto-fill when ticket number is entered
                if newValue.count >= 6 {
                    Task {
                        await viewModel.autoFillFromTicket(newValue)
                    }
                }
            }
            
            // Flight Number
            InputField(
                title: "Flight Number",
                text: $viewModel.flightNumber,
                placeholder: ""
            )
            
            // Travel Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Travel Date")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.black)
                
                DatePicker("", selection: $viewModel.travelDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(AppColors.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.emptyCard, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Reusable Input Field Component
struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.black)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(AppColors.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.emptyCard, lineWidth: 1)
                )
        }
    }
}
