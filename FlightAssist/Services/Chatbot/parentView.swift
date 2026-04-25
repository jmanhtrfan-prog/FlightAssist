//
//  parentView.swift
//  FlightAssist
//
//  Created by Danyah ALbarqawi on 25/04/2026.
//

//
//  ParentInfoStepView.swift
//  FlightAssist
//
//  Step 3: Parent / Legal Guardian Information
//

import SwiftUI

struct ParentInfoStepView: View {
    @ObservedObject var viewModel: UMBookingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Parent Full Name
            InputField(
                title: "Parent / Legal Guardian Full Name",
                text: $viewModel.parentFullName,
                placeholder: ""
            )
            
            // Parent ID / Passport
            InputField(
                title: "ID / Residence Permit / Passport Number",
                text: $viewModel.parentID,
                placeholder: ""
            )
            
            // Flight Number
            InputField(
                title: "Flight Number",
                text: $viewModel.flightNumberParent,
                placeholder: ""
            )
            
            // Confirmation Checkbox
            ConfirmationCheckbox(
                isChecked: $viewModel.confirmationChecked,
                childName: viewModel.childFullName,
                passportID: viewModel.parentID
            )
        }
    }
}

// MARK: - Confirmation Checkbox Component
struct ConfirmationCheckbox: View {
    @Binding var isChecked: Bool
    let childName: String
    let passportID: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                isChecked.toggle()
            }
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isChecked ? AppColors.primary : AppColors.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("I confirm that the information provided is accurate.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.black)
                    
                    HStack(spacing: 16) {
                        if !childName.isEmpty {
                            Text(childName)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.gray)
                        }
                        
                        if !passportID.isEmpty {
                            Text("Passport or ID: \(passportID)")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(AppColors.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isChecked ? AppColors.primary.opacity(0.3) : AppColors.emptyCard, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
