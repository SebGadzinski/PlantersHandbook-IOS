//
//  Validation.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-12.
//

import Foundation
import EmailValidator
import Navajo_Swift

///Validation.swift - Contains static functions that are used for validating
struct Validation{
    
    ///Validates given email returns "Success" or "Unacceptable email"
    ///- Parameter email: A given email
    static func emailValidator(email : String) -> String{
        return (EmailValidator.validate(email: email) ? "Success" : "Unacceptable email")
    }
    
    ///Validates given password in terms of strength, and returns "Success" or "Password is too weak" + any other reasons
    ///- Parameter password: A given password
    static func passwordValidator(password : String) -> String{
        let strength = Navajo.strength(ofPassword: password)
        if strength == PasswordStrength.weak || strength == PasswordStrength.veryWeak{
            return "Password is too weak"
        }
        let lengthRule = LengthRule(min: 6, max: 24)
        let uppercaseRule = RequiredCharacterRule(preset: .uppercaseCharacter)
        let lowercaseRule = RequiredCharacterRule(preset: .lowercaseCharacter)
        let numberRule = RequiredCharacterRule(preset: .decimalDigitCharacter)
        let symbolRule = RequiredCharacterRule(preset: .symbolCharacter)

        let validator = PasswordValidator(rules: [lengthRule, uppercaseRule, lowercaseRule, numberRule, symbolRule])

        if let failingRules = validator.validate(password) {
            return failingRules.map({ return $0.localizedErrorDescription }).joined(separator: ", ")
        } else {
            return "Success"
        }
    }

    ///Validates confirming password  in terms of password given, and returns "Success" or "Passwords don't match up"
    ///- Parameter password: A given password
    ///- Parameter confirmingPassword: A given confriming password
    static func passwordConfirmValidator(password : String, confirmingPassword: String) -> String{
        return (password == confirmingPassword ? "Success" : "Passwords don't match up")
    }

    ///Validates company name, returns "Success" or "Unacceptable name"
    ///- Parameter companyName: A given company name
    static func companyValidator(companyName : String) -> String{
        return (companyName != "" ? "Success" : "Unacceptable name")
    }

}
