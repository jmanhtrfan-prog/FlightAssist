//
//  AppState.swift
//  FlightAssist
//
//  Created by Jumana on 20/10/1447 AH.
//

import SwiftUI
import CloudKit

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var currentUser: CKRecord?
    @Published var cloudRecordName: String = ""
    @Published var currentUserSeat: String = ""
    @Published var deviceToken: String = ""

    var currentUserName: String {
        currentUser?["Name"] as? String ?? ""
    }
}
