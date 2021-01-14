//
//  Functions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import EmailValidator
import Navajo_Swift

func emailValidator(email : String) -> String{
    return (EmailValidator.validate(email: email) ? "Success" : "Unacceptable email")
}

func passwordValidator(password : String) -> String{
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

func passwordConfirmValidator(password : String, confirmingPassword: String) -> String{
    return (password == confirmingPassword ? "Success" : "Passwords don't match up")
}

func companyValidator(companyName : String) -> String{
    return (companyName != "" ? "Success" : "Unacceptable email")
}
