//
//  formView.swift
//  FlightAssist
//
//  Created by Danyah ALbarqawi on 25/04/2026.
//

//
//  LiabilityFormView.swift
//  FlightAssist
//
//  Step 4: Liability and Acknowledgment Form
//

import SwiftUI

struct LiabilityFormView: View {
    @ObservedObject var viewModel: UMBookingViewModel
    @State private var termsAccepted: Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Acknowledgment and")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.black)
                
                Text("Limitation of Liability Form for Unaccompanied Minor Travel")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.white)
            .cornerRadius(16)
            
            // Scrollable Legal Text
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Acknowledgment Section
                    SectionTitle(text: "Acknowledgment:")
                    
                    LegalText(text: "I, the parent / legal guardian signing below, acknowledge the following:")
                    
                    BulletPoint(text: "I retain the required forms and a copy of the ticket, whether paper or electronic, and will present them upon request by Saudia staff or agents.")
                    
                    BulletPoint(text: "I understand that if I fail to provide these documents, boarding/travel may be denied and the reservation may be canceled.")
                    
                    BulletPoint(text: "Saudia has the right to deny any request for rebooking or refunds according to its approved policy.")
                    
                    BulletPoint(text: "I commit to providing all documents necessary for the child's travel, including: passport, visa, health certificate, and proof of relationship or guardianship, and to disclose any special requirements or needs of the child, as well as related governmental requirements in the departure and arrival countries.")
                    
                    BulletPoint(text: "I acknowledge that without these documents, the child will not be accepted for travel.")
                    
                    BulletPoint(text: "I also commit to accompany the child until departure, and I undertake to be personally present and bear the necessary costs if the authorized guardian is not available to receive the child at the destination.")
                    
                    BulletPoint(text: "This is in accordance with international regulations and agreements protecting children's rights.")
                    
                    // Responsibilities Section
                    SectionTitle(text: "Responsibilities and Contingencies:")
                    
                    NumberedPoint(number: "1", text: "I acknowledge that Saudia's responsibility is limited to transporting the child from the departure station to the arrival station, and does not include any responsibility before pick-up or after handing over the child to the authorized person.")
                    
                    NumberedPoint(number: "2", text: "I understand that unforeseen events may occur, such as adverse weather or operational conditions, which may disrupt the flight schedule, including diversion or accommodation at a location other than the scheduled departure or arrival point.")
                    
                    SubBulletPoint(text: "If an overnight stay is required, I agree to provide transportation and accommodation for the child, including transport to/from the hotel and staying in a separate room during the stopover.")
                    
                    NumberedPoint(number: "3", text: "If the child is not received at the arrival station after attempts to contact the designated recipient, I authorize Saudia or its representative to coordinate with competent authorities, including local authorities or child protection agencies, to take necessary actions for the child's care.")
                    
                    SubBulletPoint(text: "I agree to bear all costs resulting from this, including but not limited to transportation, accommodation, and any other necessary expenses for the child's safety.")
                }
                .padding(20)
            }
            .frame(height: 400)
            .background(AppColors.white)
            .cornerRadius(16)
            .padding(.top, 16)
            
            // Accept Terms Checkbox
            Button(action: {
                withAnimation {
                    termsAccepted.toggle()
                    viewModel.confirmationChecked = termsAccepted
                }
            }) {
                HStack(alignment: .center, spacing: 12) {
                    // Checkbox
                    ZStack {
                        Circle()
                            .stroke(termsAccepted ? AppColors.primary : AppColors.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if termsAccepted {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    Text("I confirm that I am the parent / legal guardian and agree to the terms and conditions")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.black)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(16)
                .background(AppColors.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(termsAccepted ? AppColors.primary.opacity(0.3) : AppColors.emptyCard, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 16)
        }
    }
}

// MARK: - Supporting Components

struct SectionTitle: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppColors.black)
            .padding(.top, 8)
    }
}

struct LegalText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(AppColors.black)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct NumberedPoint: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.black)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SubBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("  •")
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, 16)
    }
}
