//
//  SeatsServices.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI

struct SeatsServicesView: View {

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

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 0) {

                            Image("topMap")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width - 0.32, height: 299)
                                .clipShape(RoundedRectangle(cornerRadius: 42))
                                .clipped()
                                .padding(.top, -62)

                            VStack(spacing: verticalSpacing) {

                                HStack(spacing: horizontalSpacing) {

                                    imageCard(
                                        imageName: "serviceSeats",
                                        title: "Chanage\nseats"
                                    )

                                    imageCard(
                                        imageName: "اطفال",
                                        title: "Child trip"
                                    )
                                }

                                HStack(spacing: horizontalSpacing) {

                                    imageCard(
                                        imageName: "findMySeat",
                                        title: "Find my\nseat"
                                    )

                                    imageCard(
                                        imageName: "bellCard",
                                        title: "Updates"
                                    )
                                }

                                HStack(spacing: horizontalSpacing) {
                                    emptyCard
                                    emptyCard
                                }

                                HStack(spacing: horizontalSpacing) {
                                    emptyCard
                                    emptyCard
                                }

                            }
                            .padding(.top, 30)
                            .padding(.bottom, 100) // مساحة للتاب بار

                        }

                    }

                }

                bottomBar   // ثابت
            }
        }
    }
    func imageCard(
        imageName: String,
        title: String
    ) -> some View {

        ZStack(alignment: .bottomLeading) {

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 32))

            RoundedRectangle(cornerRadius: 32)
                .fill(mainPurple.opacity(0.8))
                .frame(width: cardWidth, height: cardHeight)

            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.leading, 14)
                .padding(.bottom, 14)
                .frame(width: cardWidth, height: cardHeight, alignment: .bottomLeading)
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    var emptyCard: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(
                Color(
                    red: 221/255,
                    green: 219/255,
                    blue: 223/255
                )
            )
            .frame(width: cardWidth, height: cardHeight)
    }

    var bottomBar: some View {
        HStack {
            Spacer()
            bottomItem(icon: "house.fill", title: "Home", selected: false)
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
