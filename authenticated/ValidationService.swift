//
//  ValidationService.swift
//  Just Start Testing
//
//  Created by Sneha Sharma on 4/9/22.
//  Copyright © 2022 Kilo Loco. All rights reserved.
//

import Foundation
struct ValidationService{
    func validateUsername( username: String?) throws -> String{
        guard let username = username else { throw ValidationError.invalidValue }
        guard username.count > 3 else { throw ValidationError.usernameTooShort }
        guard username.count < 20 else { throw ValidationError.usernameTooLong }
        return username

    }
    
    func validatePassword( password: String?) throws -> String{
        guard let password = password else { throw ValidationError.invalidValue }
        guard password.count >= 8 else { throw ValidationError.passwordTooShort }
        guard password.count < 20 else { throw ValidationError.passwordTooLong }
        return password
    }
}

enum ValidationError: LocalizedError {
    case invalidValue
    case passwordTooLong
    case passwordTooShort
    case usernameTooLong
    case usernameTooShort
    
    var errorDescription: String? {
        switch self {
        case .invalidValue:
            return "You have entered an invalid value."
        case .passwordTooLong:
            return "Your password is too long."
        case .passwordTooShort:
            return "Your password is too short."
        case .usernameTooLong:
            return "Your username is too long."
        case .usernameTooShort:
            return "Your username is too short."
        }
    }
}
