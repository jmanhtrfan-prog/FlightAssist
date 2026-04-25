//
//  SeatsServices.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI

struct SeatsServicesView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToSeatSelection = false
    @State private var navigateToChat = false
    @State private var navigateToHome = false
    @State private var navigateToUM = false   // ✅ جديد (UMBookingView)

    private let cardWidth: CGFloat = 150
    private let cardHeight: CGFloat = 150
    private let horizontalSpacing: CGFloat = 28
    private let verticalSpacing: CGFloat = 26

    private let mainPurple = Color(
        red: 83/255,
        green: 42/255,
        blue: 92/255
    )

    private let backgroundColor = Color(
        red: 244/255,
        green: 243/255,
        blue: 246/255
    )

    private let bottomBarColor = Color(
        red: 231/255,
        green: 223/255,
        blue: 235/255
    )

    private let secondaryTextColor = Color(
        red: 88/255,
        green: 82/255,
        blue: 94/255
    )

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    Image("topMap")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width - 0.32, height: 299)
                        .clipShape(RoundedRectangle(cornerRadius: 42))
                        .clipped()
                        .padding(.top, -62)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: verticalSpacing) {

                            HStack(spacing: horizontalSpacing) {

                                serviceButton {
                                    navigateToSeatSelection = true
                                } label: {
                                    imageCard(
                                        imageName: "serviceSeats",
                                        title: "Chanage\nseats"
                                    )
                                }

                                // ✅ Child trip → UMBookingView
                                serviceButton {
                                    navigateToUM = true
                                } label: {
                                    imageCard(
                                        imageName: "اطفال",
                                        title: "Child trip"
                                    )
                                }
                            }

                            HStack(spacing: horizontalSpacing) {

                                serviceButton {
                                } label: {
                                    imageCard(
                                        imageName: "bellCard",
                                        title: "Updates"
                                    )
                                }

                                serviceButton {
                                    navigateToChat = true
                                } label: {
                                    chatCard(title: "Chat bot")
                                }
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                    }
                }

                bottomBar
            }

            // Seat Selection
            .navigationDestination(isPresented: $navigateToSeatSelection) {
                SeatSelectionView()
                    .navigationBarBackButtonHidden(true)
            }

            // Chat
            .navigationDestination(isPresented: $navigateToChat) {
                ChatbotView()
                    .navigationBarBackButtonHidden(true)
            }

            // Home
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }

            // ✅ UM Booking View
            .navigationDestination(isPresented: $navigateToUM) {
                UMBookingView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    func serviceButton<Content: View>(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Content
    ) -> some View {
        Button(action: action) {
            label()
        }
        .buttonStyle(.plain)
    }

    func imageCard(
        imageName: String,
        title: String
    ) -> some View {

        ZStack(alignment: .bottomLeading) {

            RoundedRectangle(cornerRadius: 32)
                .fill(mainPurple)
                .frame(width: cardWidth, height: cardHeight)

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: imageName == "bellCard" ? 140 : cardWidth,
                    height: imageName == "bellCard" ? 140 : cardHeight
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .clipped()

            RoundedRectangle(cornerRadius: 32)
                .fill(mainPurple.opacity(0.35))
                .frame(width: cardWidth, height: cardHeight)

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.leading, 14)
                .padding(.bottom, 14)
                .frame(
                    width: cardWidth,
                    height: cardHeight,
                    alignment: .bottomLeading
                )
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }

    func chatCard(title: String) -> some View {
        ZStack(alignment: .bottomLeading) {

            RoundedRectangle(cornerRadius: 32)
                .fill(mainPurple)
                .frame(width: cardWidth, height: cardHeight)

            ZStack {
                Image("Chat2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x: -14, y: -15)

                Image("Chat1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 78, height: 78)
                    .offset(x: 24, y: 1)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipped()

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 14)
                .padding(.bottom, 14)
                .frame(
                    width: cardWidth,
                    height: cardHeight,
                    alignment: .bottomLeading
                )
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }

    var bottomBar: some View {
        HStack {
            Spacer()
            Button {
                navigateToHome = true
            } label: {
                bottomItem(icon: "house.fill", title: "Home", selected: false)
            }
            .buttonStyle(.plain)

            Spacer()
            bottomItem(icon: "square.grid.2x2.fill", title: "Survices", selected: true)
            Spacer()
            bottomItem(icon: "person", title: "Profile", selected: false)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, -15)
        .background(bottomBarColor)
    }

    func bottomItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {

            ZStack {
                if selected {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(mainPurple.opacity(0.14))
                        .frame(width: 84, height: 46)
                }

                Image(systemName: icon)
                    .font(.system(size: 21))
                    .foregroundColor(
                        selected ? mainPurple : secondaryTextColor
                    )
            }

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    selected ? mainPurple : secondaryTextColor
                )
        }
    }
}

#Preview {
    SeatsServicesView()
}
