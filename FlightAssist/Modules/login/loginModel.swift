//
//  loginModel.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI

struct LoginModel {
    
    var username: String = ""
    var password: String = ""
    var showPassword: Bool = false
    
    static let primary = AppColors.primary
    static let secondary = AppColors.secondary
    static let darkPurple = AppColors.darkPurple
    static let cardPurple = AppColors.cardPurple
    
    static let white = AppColors.white
    static let black = AppColors.black
    static let textFieldBackground = AppColors.textFieldBackground
    static let background = AppColors.background
    static let emptyCard = AppColors.emptyCard
}
