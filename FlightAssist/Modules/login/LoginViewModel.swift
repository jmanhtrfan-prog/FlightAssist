//
//  LoginViewModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import Foundation

final class LoginViewModel: ObservableObject {
    
    @Published var loginModel = LoginModel()
    
    func togglePasswordVisibility() {
        loginModel.showPassword.toggle()
    }
    
    func login() {
        // Login logic here
    }
    
    func forgotPassword() {
        // Forgot password logic here
    }
}
