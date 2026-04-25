//
//  SeatSwapView.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI

// MARK: - Seat Icon

struct SeatIcon: View {
    let seat: Seat
    let isCurrentUser: Bool
    let onTap: () -> Void

    private let W: CGFloat = 46
    private let H: CGFloat = 52

    var fill: Color {
        if isCurrentUser         { return Color(hex: "#1C1C1E") }
        if seat.isSelected       { return Color(hex: "#5AC8FA") }
        return seat.status.fillColor
    }
    var stroke: Color {
        if isCurrentUser         { return Color(hex: "#000000") }
        if seat.isSelected       { return Color(hex: "#0A84FF") }
        return seat.status.strokeColor
    }
    var labelColor: Color {
        if isCurrentUser         { return .white }
        if seat.isSelected       { return .white }
        return seat.status.labelColor
    }

    var body: some View {
        Button(action: {
            guard !isCurrentUser, seat.status != .unavailable else { return }
            onTap()
        }) {
            ZStack {
                Canvas { ctx, size in
                    let w = size.width, h = size.height
                    let back = Path(roundedRect: CGRect(x: 4, y: 1, width: w-8, height: h*0.42), cornerRadius: 8)
                    ctx.fill(back, with: .color(fill))
                    ctx.stroke(back, with: .color(stroke), lineWidth: 1.5)
                    let cush = Path(roundedRect: CGRect(x: 0, y: h*0.36, width: w, height: h*0.64), cornerRadius: 10)
                    ctx.fill(cush, with: .color(fill))
                    ctx.stroke(cush, with: .color(stroke), lineWidth: 1.5)
                }
                .frame(width: W, height: H)

                Text(seat.label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(labelColor)
                    .offset(y: 8)
            }
            .frame(width: W, height: H)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(seat.isSelected ? 1.07 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: seat.isSelected)
    }
}

// MARK: - Legend

struct LegendRow: View {
    var body: some View {
        HStack(spacing: 14) {
            legendItem(color: .white,               stroke: Color(hex:"#CCCCCC"), label: "Available")
            legendItem(color: Color(hex:"#EF4E8A"), stroke: .clear,              label: "Female")
            legendItem(color: Color(hex:"#6B52B8"), stroke: .clear,              label: "Male")
            legendItem(color: Color(hex:"#C8C8C8"), stroke: .clear,              label: "N/A")
            legendItem(color: Color(hex:"#1C1C1E"), stroke: .clear,              label: "Your Seat")
        }
    }

    func legendItem(color: Color, stroke: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 15, height: 15)
                .overlay(Circle().stroke(stroke, lineWidth: 1))
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
        }
    }
}

// MARK: - Section

struct SeatSection: View {
    let seats: [[Seat]]
    let currentUserSeat: String
    let onTap: (Int, Int) -> Void

    var body: some View {
        VStack(spacing: 7) {
            ForEach(seats.indices, id: \.self) { r in
                HStack(spacing: 5) {
                    ForEach(seats[r].indices, id: \.self) { c in
                        SeatIcon(
                            seat: seats[r][c],
                            isCurrentUser: seats[r][c].label == currentUserSeat
                        ) { onTap(r, c) }
                    }
                }
            }
        }
    }
}

// MARK: - Main View

struct SeatSelectionView: View {
    @StateObject private var vm = SeatSelectionViewModel()
    @ObservedObject private var appState = AppState.shared
    @Environment(\.dismiss) private var dismiss  // ✅ للرجوع لـ SeatsServicesView

    let headerBg = Color(hex: "#2C1654")
    let cardBg   = Color.white
    let pageBg   = Color(hex: "#E0DCEC")

    var body: some View {
        ZStack {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────
                VStack(spacing: 14) {
                    ZStack {
                        HStack {
                            // ✅ زر الرجوع يرجع لـ SeatsServicesView
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        Text("Select a Seat")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)

                    LegendRow()
                }
                .padding(.top, 16)
                .padding(.bottom, 22)
                .background(headerBg)

                // ── White card ───────────────────────────────
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 28).fill(cardBg)

                        HStack(alignment: .top, spacing: 0) {
                            Spacer(minLength: 12)

                            SeatSection(seats: vm.leftSeats, currentUserSeat: appState.currentUserSeat) { r, c in
                                vm.toggleLeft(row: r, col: c)
                            }
                            Spacer(minLength: 10)
                            SeatSection(seats: vm.middleSeats, currentUserSeat: appState.currentUserSeat) { r, c in
                                vm.toggleMiddle(row: r, col: c)
                            }
                            Spacer(minLength: 10)
                            SeatSection(seats: vm.rightSeats, currentUserSeat: appState.currentUserSeat) { r, c in
                                vm.toggleRight(row: r, col: c)
                            }

                            Spacer(minLength: 12)
                        }
                        .padding(.vertical, 24)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }

                // ── Bottom Bar ───────────────────────────────
                if vm.canConfirm {
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            HStack(spacing: 8) {
                                Text(appState.currentUserSeat)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color(hex: "#1C1C1E"))
                                    .cornerRadius(8)

                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(hex: "#6B52B8"))

                                Text(vm.selectedSeats.map { $0.label }.joined())
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color(hex: "#5AC8FA"))
                                    .cornerRadius(8)
                            }

                            Spacer()

                            Button(action: vm.confirmSelection) {
                                if vm.isSendingRequest {
                                    ProgressView().tint(.white)
                                        .padding(.horizontal, 20).padding(.vertical, 10)
                                } else {
                                    Text("Send Request")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20).padding(.vertical, 10)
                                }
                            }
                            .background(Color(hex: "#6B52B8"))
                            .cornerRadius(12)
                            .disabled(vm.isSendingRequest)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                    }
                }
            }
        }
        .alert("Request Sent!", isPresented: $vm.requestSent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your swap request has been sent. Waiting for approval.")
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

#Preview {
    SeatSelectionView()
}
