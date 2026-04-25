//
//  AdminView.swift
//  FlightAssist
//
//  Created by Jumana on 08/11/1447 AH.
//

import SwiftUI

struct AdminView: View {

    // MARK: - UI

    private let cardWidth: CGFloat = 165
    private let cardHeight: CGFloat = 165
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

    // MARK: - Model

    struct ServiceItem: Identifiable {
        let id: String
        var title: String
        var image: String
        var isDisabled: Bool = false
    }

    // MARK: - State

    @State private var isEditing = false

    @State private var services: [ServiceItem] = [
        ServiceItem(id: "seats", title: "Change\nseats", image: "serviceSeats"),
        ServiceItem(id: "child", title: "Child trip", image: "اطفال"),
        ServiceItem(id: "updates", title: "Updates", image: "bellCard"),
        ServiceItem(id: "chat", title: "Chat bot", image: "Chat")
    ]

    @State private var selectedIndex: Int? = nil
    @State private var showRenamePopup = false
    @State private var showDisablePopup = false
    @State private var newName = ""

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    ZStack(alignment: .topTrailing) {

                        Image("topMap")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width - 0.32, height: 299)
                            .clipShape(RoundedRectangle(cornerRadius: 42))
                            .clipped()

                        Button {
                            isEditing.toggle()
                        } label: {
                            Image("editTop")
                                .resizable()
                                .frame(width: 44, height: 44)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 16)
                    }
                    .padding(.top, -62)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: verticalSpacing) {

                            HStack(spacing: horizontalSpacing) {
                                imageCard(service: $services[0])
                                imageCard(service: $services[1])
                            }

                            HStack(spacing: horizontalSpacing) {
                                imageCard(service: $services[2])
                                imageCard(service: $services[3])
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                    }
                }

                if showRenamePopup { popupRename }
                if showDisablePopup { popupDisable }

                bottomBar
            }
        }
    }

    // MARK: - Card

    func imageCard(service: Binding<ServiceItem>) -> some View {

        let isDisabled = service.wrappedValue.isDisabled

        return ZStack {

            RoundedRectangle(cornerRadius: 32)
                .fill(isDisabled ? Color.gray.opacity(0.45) : mainPurple)
                .frame(width: cardWidth, height: cardHeight)

            if service.wrappedValue.id == "chat" {

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
                .opacity(isDisabled ? 0.3 : 1)

            } else {

                Image(service.wrappedValue.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .opacity(isDisabled ? 0.3 : 1)

                RoundedRectangle(cornerRadius: 32)
                    .fill(mainPurple.opacity(0.35))
                    .frame(width: cardWidth, height: cardHeight)
            }

            VStack {
                Spacer()
                HStack {
                    Text(service.wrappedValue.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white.opacity(isDisabled ? 0.6 : 1))
                        .padding(14)
                    Spacer()
                }
            }

            if isDisabled {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.gray.opacity(0.25))
            }

            if isEditing {
                VStack {
                    HStack {
                        Spacer()

                        HStack(spacing: 10) {

                            Button {
                                if let index = services.firstIndex(where: { $0.id == service.wrappedValue.id }) {
                                    selectedIndex = index
                                    newName = services[index].title
                                    showRenamePopup = true
                                }
                            } label: {
                                Image("editIcon")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(8)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(Circle())
                            }

                            Button {
                                if let index = services.firstIndex(where: { $0.id == service.wrappedValue.id }) {
                                    selectedIndex = index
                                    showDisablePopup = true
                                }
                            } label: {
                                Image("disableIcon")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(8)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(10)
                    }

                    Spacer()
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
    // MARK: - Rename Popup

    var popupRename: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { showRenamePopup = false }

            VStack(spacing: 16) {

                Text("Enter new name")
                    .font(.system(size: 16, weight: .medium))

                TextField("Name", text: $newName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)

                Button {
                    if let index = selectedIndex {
                        services[index].title = newName
                    }
                    showRenamePopup = false
                } label: {
                    Text("Rename")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mainPurple)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(40)
        }
    }

    // MARK: - Disable Popup

    var popupDisable: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { showDisablePopup = false }

            VStack(spacing: 16) {

                let isDisabled = selectedIndex != nil ? services[selectedIndex!].isDisabled : false

                Text(isDisabled ? "Resume this feature" : "Disable this feature temporarily")
                    .font(.system(size: 16, weight: .semibold))

                Text(isDisabled ? "This feature will be resumed" : "Are you sure you want to disable this feature?")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                VStack(spacing: 10) {

                    Button {
                        if let index = selectedIndex {
                            services[index].isDisabled.toggle()
                        }
                        showDisablePopup = false
                    } label: {
                        Text(isDisabled ? "Resume" : "Disable")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mainPurple)
                            .cornerRadius(14)
                    }

                    Button {
                        showDisablePopup = false
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(40)
        }
    }

    // MARK: - Bottom Bar

    var bottomBar: some View {
        HStack {
            Spacer()
            bottomItem(icon: "house.fill", title: "Home", selected: true)
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
            Image(systemName: icon)
                .font(.system(size: 21))
                .foregroundColor(selected ? mainPurple : secondaryTextColor)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(selected ? mainPurple : secondaryTextColor)
        }
    }
}

#Preview {
    AdminView()
}
