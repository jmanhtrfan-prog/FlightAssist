//
//  AppState.swift
//  FlightAssist
//
//  Created by Jumana on 20/10/1447 AH.
//
import CloudKit

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var currentUser: CKRecord?
}
