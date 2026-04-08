//
//  HomeView.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI
import VisionKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showScanner = false

    private let mapAssetName = "topMap"
    private let seatsAssetName = "serviceSeats"

    private let lightCard = Color(red: 247/255, green: 241/255, blue: 246/255)
    private let serviceColor = Color(red: 83/255, green: 42/255, blue: 92/255)

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topMapSection

                mainCard
                    .padding(.top, -3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
        }
        // ✅ هنا حطينا الشيت الجديد
        .sheet(isPresented: $showScanner) {
            TicketScannerView(
                onScan: { scannedText in
                    showScanner = false
                    let userID = AppState.shared.currentUser?.recordID.recordName ?? ""
                    let scanVM = TicketScannerViewModel()
                    scanVM.parseAndSave(scannedText: scannedText, userID: userID)
                },
                onError: { error in
                    showScanner = false
                    viewModel.scannerError = error
                }
            )
        }
        .alert(
            "Scanner",
            isPresented: Binding(
                get: { viewModel.scannerError != nil },
                set: { _ in viewModel.scannerError = nil }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.scannerError ?? "")
        }
    }
}

// باقي الكود كما هو بدون أي تغيير
private extension HomeView {

    var topMapSection: some View {
        VStack(spacing: 0) {
            Image(mapAssetName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 28)
                )
                .padding(.horizontal, -1)
                .padding(.top, -65)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    var mainCard: some View {
        VStack(spacing: 18) {
            if let info = viewModel.boardingPassInfo {
                boardingCard(info)
                    .padding(.top, 46)
            } else {
                scanBox
                    .padding(.top, 46)
            }

            searchBar

            if !viewModel.recentServices.isEmpty {
                recentServicesSection
            }

            Spacer(minLength: 0)

            bottomBar
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    var scanBox: some View {
        Button {
            // نتأكد إن الجهاز يدعم DataScannerViewController
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                showScanner = true
            } else {
                // رسالة واضحة للمستخدم
                viewModel.scannerError = "Scanning is only available on a real iPhone running iOS 16 or later with camera access."
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "camera")
                    .font(.system(size: 34, weight: .regular))

                Text("Scan the ticket")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.black)
            .frame(width: 220, height: 150)
            .background(lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
    var searchBar: some View {
        HStack(spacing: 8) {
            Text("Hinted search text")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(.gray.opacity(0.8))
        }
        .padding(.horizontal, 18)
        .frame(height: 54)
        .background(lightCard)
        .clipShape(Capsule())
    }

    var recentServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent  services")
                .font(.system(size: 17))
                .foregroundColor(.gray.opacity(0.9))

            HStack(spacing: 14) {
                ForEach(viewModel.recentServices, id: \.self) { service in
                    recentServiceCard(title: service)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func recentServiceCard(title: String) -> some View {
        Button {
            viewModel.saveRecentService(title)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(serviceColor)
                    .frame(height: 66)

                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(seatsAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 74, height: 42)
                }
                .padding(.leading, 16)
                .padding(.trailing, 10)
            }
        }
    }

    func boardingCard(_ info: BoardingPassInfo) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(info.fullName)
                .font(.title3.bold())
                .foregroundColor(.black)

            HStack {
                infoItem("Flight", info.flightNumber)
                Spacer()
                infoItem("From", info.from)
                Spacer()
                infoItem("To", info.to)
            }

            Divider()

            HStack {
                infoItem("Gate", info.gate)
                Spacer()
                infoItem("Seat", info.seat)
                Spacer()
                infoItem("Boarding", info.boardingTime)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    func infoItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.body.bold())
                .foregroundColor(.black)
        }
    }

    var bottomBar: some View {
        HStack {
            Spacer()
            bottomItem(icon: "house.fill", title: "Home", selected: true)
            Spacer()
            bottomItem(icon: "square.grid.2x2.fill", title: "Services", selected: false)
            Spacer()
            bottomItem(icon: "person", title: "Profile", selected: false)
            Spacer()
        }
        .padding(.top, 18)
        .padding(.bottom, 6)
    }

    func bottomItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(selected ? .black : .gray.opacity(0.8))

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(selected ? .black : .gray.opacity(0.8))
        }
    }
}

#Preview {
    let defaults = UserDefaults.standard
    defaults.set("Find my\nseat,Change\nseats", forKey: "recentServicesStorage")
    return HomeView()
}
