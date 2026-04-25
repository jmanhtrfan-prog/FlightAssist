//
//  UMConfirmationView.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

//
//  UMConfirmationView.swift
//  FlightAssist
//
//  Step 5: Booking Confirmation
//

import SwiftUI

struct UMConfirmationView: View {
    @ObservedObject var viewModel: UMBookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primary)
            }
            .padding(.bottom, 32)
            
            // Title
            Text("Booking Confirmed!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.black)
                .padding(.bottom, 12)
            
            // Subtitle
            Text("Your UM service booking has been successfully submitted.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            
            // Booking Details Card
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(
                    icon: "ticket.fill",
                    title: "Booking Reference",
                    value: viewModel.bookingReference
                )
                
                Divider()
                
                DetailRow(
                    icon: "airplane",
                    title: "Flight Number",
                    value: viewModel.flightNumber
                )
                
                Divider()
                
                DetailRow(
                    icon: "person.fill",
                    title: "Child Name",
                    value: viewModel.childFullName
                )
                
                Divider()
                
                DetailRow(
                    icon: "calendar",
                    title: "Travel Date",
                    value: formattedDate(viewModel.travelDate)
                )
            }
            .padding(20)
            .background(AppColors.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                // View My Bookings
                Button(action: {
                    // Navigate to bookings list
                    dismiss()
                }) {
                    Text("View My Bookings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                }
                
                // Back to Home
                Button(action: {
                    viewModel.resetBooking()
                    dismiss()
                }) {
                    Text("Back to Home")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.primary, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.background)
    }
    
    // MARK: - Helper Functions
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.black)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct UMConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        UMConfirmationView(viewModel: UMBookingViewModel())
    }
}

