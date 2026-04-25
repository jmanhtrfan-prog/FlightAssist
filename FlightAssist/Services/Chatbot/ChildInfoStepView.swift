
//
//  Childview.swift
//  FlightAssist
//
//  Created by Danyah ALbarqawi on 25/04/2026.
//

//
//  ChildInfoStepView.swift
//  FlightAssist
//
//  Step 2: Child Information
//

import SwiftUI

struct ChildInfoStepView: View {
    @ObservedObject var viewModel: UMBookingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Child Full Name
            InputField(
                title: "Child Full Name",
                text: $viewModel.childFullName,
                placeholder: ""
            )
            
            // Child ID / Passport
            InputField(
                title: "ID / Residence Permit / Passport Number",
                text: $viewModel.childID,
                placeholder: ""
            )
        }
    }
}
