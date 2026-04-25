//
//  LoginViewModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import Foundation
import CloudKit

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var loginModel = LoginModel()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false

    private let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase

    func togglePasswordVisibility() {
        loginModel.showPassword.toggle()
    }

    func login() {
        Task {
            guard !loginModel.username.isEmpty, !loginModel.password.isEmpty else {
                errorMessage = "Please fill in all fields"
                return
            }

            isLoading = true
            errorMessage = nil

            do {
                let predicate = NSPredicate(format: "Email == %@", loginModel.username)
                let query = CKQuery(recordType: "User", predicate: predicate)
                let result = try await db.records(matching: query)

                guard let record = try result.matchResults.first?.1.get() else {
                    errorMessage = "User not found"
                    isLoading = false
                    return
                }

                let storedPassword = record["Password"] as? String ?? ""
                guard storedPassword == loginModel.password else {
                    errorMessage = "Incorrect password"
                    isLoading = false
                    return
                }

                print("🔍 recordID.recordName = \(record.recordID.recordName)")

                AppState.shared.currentUser = record
                AppState.shared.cloudRecordName = record.recordID.recordName

                NotificationManager.shared.subscribeToSwapRequests(for: record.recordID.recordName)

                isLoggedIn = true

            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func forgotPassword() { }
}
