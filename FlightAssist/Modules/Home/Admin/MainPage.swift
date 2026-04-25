//
//  MainPage.swift
//  FlightAssist
//
//  Created by danah alsadan on 08/11/1447 AH.
//

import SwiftUI

struct MainPage: View {

    private let cardWidth: CGFloat = 165
    private let cardHeight: CGFloat = 165
    private let horizontalSpacing: CGFloat = 28
    private let verticalSpacing: CGFloat = 26

    private let mainPurple = Color(red: 83/255, green: 42/255, blue: 92/255)
    private let backgroundColor = Color(red: 244/255, green: 243/255, blue: 246/255)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {

                    Image("topMap")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 299)
                        .clipShape(RoundedRectangle(cornerRadius: 42))
                        .clipped()
                        .padding(.top, -62)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: verticalSpacing) {

                            HStack(spacing: horizontalSpacing) {
                                roleCard(title: "Passenger", image: "passenger")
                                roleCard(title: "Child", image: "child")
                            }

                            HStack {
                                roleCard(title: "Services", image: "services")
                                Spacer()
                            }
                            .frame(
                                width: (cardWidth * 2) + horizontalSpacing,
                                alignment: .leading
                            )
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    func roleCard(title: String, image: String) -> some View {
        Button {
            print("\(title) tapped")
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(mainPurple)
                    .frame(width: cardWidth, height: cardHeight)

                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

                RoundedRectangle(cornerRadius: 32)
                    .fill(mainPurple.opacity(0.35))

                VStack {
                    Spacer()
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .padding(14)
                        Spacer()
                    }
                }
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainPage()
}
