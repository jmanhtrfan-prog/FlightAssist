//
//  Welcome.swift
//  FlightAssist
//
//  Created by danah alsadan on 29/10/1447 AH.
//

import SwiftUI

struct SupervisorHomeView: View {
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [AppColors.supervisorPurpleLight, AppColors.supervisorPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 234)
                        .clipShape(
                            RoundedCorner(radius: 59, corners: [.bottomLeft, .bottomRight])
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome, Supervisor")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("Danah Abdullah")
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .offset(y: -62)
                    .padding(.bottom, -45)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Seat Change Requests")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("Pending: 2")
                                        .font(.system(size: 12))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.pendingColor)
                                        .cornerRadius(8)
                                }
                                
                                Divider()
                                
                                Text("Passenger A wants to swap from")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Text("16A  >  18C")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Text("Pending")
                                        .font(.system(size: 12))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.pendingColor)
                                        .cornerRadius(8)
                                }
                                
                                NavigationLink {
                                    ManageView(initialTab: .seatSwap)
                                } label: {
                                    Text("View All")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(AppColors.supervisorPurple)
                                        .cornerRadius(25)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 16)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("UM Child Updates")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("Active")
                                        .font(.system(size: 12))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.activeColor)
                                        .cornerRadius(8)
                                }
                                
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sara Ahmad (9Y) Seated safely at 1A")
                                            .font(.system(size: 13))
                                        
                                        Text("5m ago")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                
                                NavigationLink {
                                    ManageView(initialTab: .umUpdates)
                                } label: {
                                    Text("Open Updates")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(AppColors.supervisorPurple)
                                        .cornerRadius(25)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                bottomBar
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var bottomBar: some View {
        HStack {
            Spacer()
            
            bottomItem(icon: "house.fill", title: "Home", selected: true)
            
            Spacer()
            
            NavigationLink {
                ManageView(initialTab: .seatSwap)
            } label: {
                bottomItem(icon: "square.grid.2x2.fill", title: "Requests", selected: false)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            bottomItem(icon: "person", title: "Profile", selected: false)
            
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, -15)
        .background(
            Color(
                red: 231/255,
                green: 223/255,
                blue: 235/255
            )
        )
    }
    
    private func bottomItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if selected {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(AppColors.supervisorPurple.opacity(0.14))
                        .frame(width: 84, height: 46)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 21))
                    .foregroundColor(
                        selected ? AppColors.supervisorPurple :
                        Color(red: 88/255, green: 82/255, blue: 94/255)
                    )
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    selected ? AppColors.supervisorPurple :
                    Color(red: 88/255, green: 82/255, blue: 94/255)
                )
        }
    }
}

#Preview {
    SupervisorHomeView()
}
