//
//  ChildrenInformationView.swift
//  FlightAssist
//
//  Created by danah alsadan on 08/11/1447 AH.
//
import SwiftUI

struct ChildrenInformationView: View {
    
    private let mainPurple = Color(red: 83/255, green: 42/255, blue: 92/255)
    private let pageBackground = Color(red: 244/255, green: 243/255, blue: 246/255)
    private let editPurple = Color(red: 201/255, green: 64/255, blue: 255/255)
    
    struct ChildItem: Identifiable {
        let id = UUID()
        var name: String
        var isDeleted: Bool = false
    }
    
    // فاضية عشان تجي من CloudKit بعدين
    @State private var children: [ChildItem] = []
    
    @State private var selectedChildID: UUID?
    @State private var showDeleteAlert = false
    
    @State private var selectedChildForEditID: UUID?
    @State private var showEditOptions = false
    @State private var showRenameAlert = false
    @State private var newName = ""
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    if children.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.crop.square.stack")
                                .font(.system(size: 50))
                                .foregroundColor(mainPurple.opacity(0.4))
                            
                            Text("No children yet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding(.top, 80)
                    } else {
                        VStack(spacing: 18) {
                            ForEach($children) { $child in
                                childCard(child: $child)
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
        
        .alert("Delete Child", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Delete", role: .destructive) {
                if let selectedChildID,
                   let index = children.firstIndex(where: { $0.id == selectedChildID }) {
                    children[index].isDeleted = true
                }
            }
        } message: {
            Text("Are you sure you want to delete this child?")
        }
        
        .confirmationDialog("Edit Child", isPresented: $showEditOptions) {
            Button("Rename") {
                if let selectedChildForEditID,
                   let child = children.first(where: { $0.id == selectedChildForEditID }) {
                    newName = child.name
                    showRenameAlert = true
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        
        .alert("Rename Child", isPresented: $showRenameAlert) {
            TextField("New name", text: $newName)
            
            Button("Save") {
                if let selectedChildForEditID,
                   let index = children.firstIndex(where: { $0.id == selectedChildForEditID }) {
                    children[index].name = newName
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var header: some View {
        ZStack {
            mainPurple
            
            Text("Child")
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
    
    private func childCard(child: Binding<ChildItem>) -> some View {
        let isDeleted = child.wrappedValue.isDeleted
        
        return HStack(spacing: 14) {
            
            Circle()
                .fill(isDeleted ? Color.gray.opacity(0.20) : mainPurple.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: isDeleted ? "person.slash.fill" : "person.fill")
                        .foregroundColor(isDeleted ? .gray : mainPurple)
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(child.wrappedValue.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDeleted ? .gray : .black)
                    .lineLimit(2)
                
                if isDeleted {
                    Text("Deleted")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red.opacity(0.75))
                }
            }
            
            Spacer()
            
            if isDeleted {
                Button {
                    child.wrappedValue.isDeleted = false
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
                    selectedChildID = child.wrappedValue.id
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .frame(width: 38, height: 38)
                        .background(Color.red.opacity(0.10))
                        .clipShape(Circle())
                }
                
                Button {
                    selectedChildForEditID = child.wrappedValue.id
                    showEditOptions = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(editPurple)
                        .frame(width: 38, height: 38)
                        .background(editPurple.opacity(0.10))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 78)
        .background(isDeleted ? Color.gray.opacity(0.12) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isDeleted ? Color.gray.opacity(0.35) : mainPurple.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(isDeleted ? 0.02 : 0.06), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ChildrenInformationView()
}
