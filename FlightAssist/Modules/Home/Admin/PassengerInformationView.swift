//
//  PassengerInformationView.swift
//  FlightAssist
//
//  Created by danah alsadan on 08/11/1447 AH.
//

import SwiftUI

struct PassengerInformationView: View {
    
    private let mainPurple = Color(red: 83/255, green: 42/255, blue: 92/255)
    private let pageBackground = Color(red: 244/255, green: 243/255, blue: 246/255)
    private let editPurple = Color(red: 201/255, green: 64/255, blue: 255/255)
    
    struct PassengerItem: Identifiable {
        let id = UUID()
        var email: String
        var isDeleted: Bool = false
    }
    
    // ✅ فاضية - تنتظر الداتا بيس
    @State private var passengers: [PassengerItem] = []
    
    @State private var selectedPassengerID: UUID?
    @State private var showDeleteAlert = false
    
    @State private var selectedPassengerForEditID: UUID?
    @State private var showEditOptions = false
    @State private var showRenameAlert = false
    @State private var newEmail = ""
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    
                    if passengers.isEmpty {
                        // ✅ حالة ما فيه بيانات
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(mainPurple.opacity(0.4))
                            
                            Text("No passengers yet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding(.top, 80)
                        
                    } else {
                        VStack(spacing: 18) {
                            ForEach($passengers) { $passenger in
                                passengerCard(passenger: $passenger)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 34)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        
        .alert("Delete Passenger", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Delete", role: .destructive) {
                if let selectedPassengerID,
                   let index = passengers.firstIndex(where: { $0.id == selectedPassengerID }) {
                    passengers[index].isDeleted = true
                }
            }
        } message: {
            Text("Are you sure you want to delete this passenger?")
        }
        
        .confirmationDialog("Edit Passenger", isPresented: $showEditOptions) {
            Button("Edit Email") {
                if let selectedPassengerForEditID,
                   let passenger = passengers.first(where: { $0.id == selectedPassengerForEditID }) {
                    newEmail = passenger.email
                    showRenameAlert = true
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        
        .alert("Edit Email", isPresented: $showRenameAlert) {
            TextField("New email", text: $newEmail)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            Button("Save") {
                if let selectedPassengerForEditID,
                   let index = passengers.firstIndex(where: { $0.id == selectedPassengerForEditID }) {
                    passengers[index].email = newEmail
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var header: some View {
        ZStack {
            mainPurple
            
            Text("Passenger")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 27, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 42)
        }
        .frame(height: 150)
    }
    
    private func passengerCard(passenger: Binding<PassengerItem>) -> some View {
        let isDeleted = passenger.wrappedValue.isDeleted
        
        return HStack(spacing: 14) {
            
            Circle()
                .fill(isDeleted ? Color.gray.opacity(0.20) : mainPurple.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: isDeleted ? "person.slash.fill" : "person.fill")
                        .foregroundColor(isDeleted ? .gray : mainPurple)
                        .font(.system(size: 20))
                )
            
            Text(passenger.wrappedValue.email)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(isDeleted ? .gray : .black)
            
            Spacer()
            
            if isDeleted {
                Button {
                    passenger.wrappedValue.isDeleted = false
                } label: {
                    Text("Restore")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(mainPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(mainPurple.opacity(0.10))
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    selectedPassengerID = passenger.wrappedValue.id
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                }
                
                Button {
                    selectedPassengerForEditID = passenger.wrappedValue.id
                    showEditOptions = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(editPurple)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 78)
        .background(isDeleted ? Color.gray.opacity(0.12) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    PassengerInformationView()
}
