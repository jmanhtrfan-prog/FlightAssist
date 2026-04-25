//
//  Manage.swift
//  FlightAssist
//
//  Created by danah alsadan on 29/10/1447 AH.
//

import SwiftUI

struct ManageView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: RequestTab
    @State private var showUpdatePopup = false
    @State private var showSuccessScreen = false
    @State private var selectedUpdate: GuardianUpdateOption? = nil
    
    private let pageBackground = Color(red: 244/255, green: 241/255, blue: 246/255)
    private let bottomBarColor = Color(red: 231/255, green: 223/255, blue: 235/255)
    private let secondaryTextColor = Color(red: 88/255, green: 82/255, blue: 94/255)
    private let pendingTextColor = Color(red: 198/255, green: 140/255, blue: 39/255)
    private let activeTextColor = Color(red: 72/255, green: 143/255, blue: 228/255)
    
    init(initialTab: RequestTab = .seatSwap) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        ZStack {
            pageBackground
                .ignoresSafeArea()
            
            if showSuccessScreen {
                successScreen
            } else {
                mainContent
            }
            
            if showUpdatePopup {
                popupOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedTab == .seatSwap {
                            seatSwapContent
                        } else {
                            umUpdatesContent
                        }
                    }
                    .padding(.bottom, 110)
                }
            }
            
            bottomBar
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            AppColors.supervisorPurple
                .frame(height: 189)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 28,
                        bottomTrailingRadius: 28,
                        topTrailingRadius: 0
                    )
                )
                .padding(.top, -62)
                .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Requests")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 0) {
                    switchButton(title: "Set Swap", selected: selectedTab == .seatSwap) {
                        selectedTab = .seatSwap
                    }
                    
                    switchButton(title: "UM Updates", selected: selectedTab == .umUpdates) {
                        selectedTab = .umUpdates
                    }
                }
                .padding(4)
                .background(Color(red: 88/255, green: 23/255, blue: 102/255))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .offset(y: -1)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
    }
    
    private func switchButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selected ? .black : .white)
                .frame(width: 110, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(selected ? Color.white : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Seat Swap Content
    
    private var seatSwapContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pending requests: 2")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppColors.supervisorPurple)
                .padding(.horizontal, 18)
                .padding(.top, 22)
            
            VStack(spacing: 18) {
                seatSwapCard(
                    firstName: "Ahmad",
                    firstSeat: "Seat 16A",
                    firstSeatNumber: "16A",
                    secondName: "Amal",
                    secondSeat: "Seat 18C",
                    secondSeatNumber: "18C"
                )
                
                seatSwapCard(
                    firstName: "Abdullah",
                    firstSeat: "Seat 14A",
                    firstSeatNumber: "14A",
                    secondName: "Salman",
                    secondSeat: "Seat 17C",
                    secondSeatNumber: "17C"
                )
            }
            .padding(.horizontal, 18)
        }
    }
    
    private func seatSwapCard(
        firstName: String,
        firstSeat: String,
        firstSeatNumber: String,
        secondName: String,
        secondSeat: String,
        secondSeatNumber: String
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(firstName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(AppColors.supervisorPurple)
                    
                    Text(firstSeat)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    Text("Pending")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(pendingTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(AppColors.pendingColor)
                        .clipShape(Capsule())
                    
                    Text(firstSeatNumber)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(AppColors.supervisorPurple)
                }
            }
            
            Divider()
                .padding(.top, 14)
                .padding(.bottom, 14)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(secondName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(AppColors.supervisorPurple)
                    
                    Text(secondSeat)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(secondSeatNumber)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.supervisorPurple)
            }
            
            Button {
            } label: {
                Text("Review The Seats")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(AppColors.supervisorPurple)
                    .clipShape(Capsule())
            }
            .padding(.top, 18)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - UM Updates Content
    
    private var umUpdatesContent: some View {
        VStack {
            umCard
        }
        .padding(.horizontal, 18)
        .padding(.top, 78)
    }
    
    private var umCard: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Text("Active")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(activeTextColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(AppColors.activeColor)
                        .clipShape(Capsule())
                }
                .padding(.top, 18)
                .padding(.horizontal, 18)
                
                VStack(spacing: 6) {
                    Text("Sara Ahmad")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.supervisorPurple)
                    
                    Text("Age: 9")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.supervisorPurple)
                }
                .padding(.top, 8)
                
                Divider()
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("Last Updates: 5m ago")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.supervisorPurple)
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                
                Button {
                    selectedUpdate = nil
                    showUpdatePopup = true
                } label: {
                    Text("Send Update")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(AppColors.supervisorPurple)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 18)
                .padding(.top, 28)
                .padding(.bottom, 18)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.top, 52)
            
            Circle()
                .fill(Color.gray.opacity(0.28))
                .frame(width: 104, height: 104)
        }
    }
    
    // MARK: - Popup
    
    private var popupOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") {
                        showUpdatePopup = false
                        selectedUpdate = nil
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Send Update to Guardian")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.supervisorPurple)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 45, height: 20)
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                
                Divider()
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(GuardianUpdateOption.allCases, id: \.self) { option in
                        Button {
                            selectedUpdate = option
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .stroke(Color.black.opacity(0.8), lineWidth: 1)
                                    .frame(width: 22, height: 22)
                                    .overlay {
                                        if selectedUpdate == option {
                                            Circle()
                                                .fill(AppColors.supervisorPurple)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                
                                Text(option.rawValue)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.supervisorPurple)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                
                Button {
                    guard selectedUpdate != nil else { return }
                    showUpdatePopup = false
                    showSuccessScreen = true
                } label: {
                    Text("Send")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 40)
                        .background(AppColors.supervisorPurple)
                        .clipShape(Capsule())
                }
                .padding(.top, 26)
                .padding(.bottom, 18)
                .disabled(selectedUpdate == nil)
                .opacity(selectedUpdate == nil ? 0.6 : 1)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 26)
        }
    }
    
    // MARK: - Success Screen
    
    private var successScreen: some View {
        VStack(spacing: 0) {
            AppColors.supervisorPurple
                .frame(height: 190)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 28,
                        bottomTrailingRadius: 28
                    )
                )
                .padding(.top, -62)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            Spacer()
            
            VStack(spacing: 28) {
                Text("Update Sent Successfully")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.supervisorPurple)
                    .multilineTextAlignment(.center)
                
                Text("The guardian has been updated about\nSara Ahmad")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.supervisorPurple)
                    .multilineTextAlignment(.center)
                
                Button {
                    showSuccessScreen = false
                    showUpdatePopup = false
                    selectedTab = .umUpdates
                    selectedUpdate = nil
                } label: {
                    Text("Done")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.supervisorPurple)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                bottomItem(icon: "house.fill", title: "Home", selected: false)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            bottomItem(icon: "square.grid.2x2.fill", title: "Requests", selected: true)
            
            Spacer()
            
            bottomItem(icon: "person", title: "Pro", selected: false)
            
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, -15)
        .background(bottomBarColor)
    }
    
    private func bottomItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if selected {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(AppColors.supervisorPurple.opacity(0.14))
                        .frame(width: 84, height: 46)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 21))
                    .foregroundColor(
                        selected ? AppColors.supervisorPurple : secondaryTextColor
                    )
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    selected ? AppColors.supervisorPurple : secondaryTextColor
                )
        }
    }
}

enum RequestTab {
    case seatSwap
    case umUpdates
}

enum GuardianUpdateOption: String, CaseIterable {
    case checkedIn = "Child checked in successfully"
    case boarded = "Child has boarded the flight"
    case seatedSafely = "Child is seated safely"
    case departed = "Flight has departed"
    case landed = "Child has landed safely"
    case handedOver = "Child has been handed over"
}

#Preview {
    ManageView()
}
