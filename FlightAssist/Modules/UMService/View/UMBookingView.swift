
//
//  UMBookingView.swift
//  FlightAssist
//
//  Main UM booking flow container
//

import SwiftUI

struct UMBookingView: View {
    @StateObject private var viewModel = UMBookingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Progress Indicator
                if viewModel.currentStep != .confirmation {
                    progressIndicator
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        currentStepView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
            
            // Continue Button (Floating)
            if viewModel.currentStep != .confirmation {
                VStack {
                    Spacer()
                    continueButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: {
                if viewModel.currentStep == .bookingInfo {
                    dismiss()
                } else {
                    viewModel.goToPreviousStep()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.black)
            }
            
            Spacer()
            
            Text(viewModel.currentStep.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.black)
            
            Spacer()
            
            // Invisible for centering
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
        .background(AppColors.white)
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= viewModel.currentStep.rawValue ? AppColors.primary : AppColors.emptyCard)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.white)
    }
    
    // MARK: - Current Step View
    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {
        case .bookingInfo:
            BookingInfoStepView(viewModel: viewModel)
        case .childInfo:
            ChildInfoStepView(viewModel: viewModel)
        case .parentInfo:
            ParentInfoStepView(viewModel: viewModel)
        case .liability:
            LiabilityFormView(viewModel: viewModel)
        case .confirmation:
            UMConfirmationView(viewModel: viewModel)
        }
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            if viewModel.currentStep == .liability {
                Task {
                    await viewModel.submitBooking()
                }
            } else {
                viewModel.continueToNextStep()
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            } else {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(viewModel.canContinue ? AppColors.primary : AppColors.gray.opacity(0.5))
        .cornerRadius(16)
        .disabled(!viewModel.canContinue)
    }
}

// MARK: - Preview
struct UMBookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UMBookingView()
        }
    }
}
