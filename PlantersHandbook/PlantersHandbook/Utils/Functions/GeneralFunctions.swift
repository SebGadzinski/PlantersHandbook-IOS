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

func getDate(from: Date) -> String {
    let curDate = Calendar.current.dateComponents([.year,.day,.month], from: from)
    return String(curDate.year!) + " " + getMonth(month: curDate.month!) + " " +  String(curDate.day!)
}

func getMonth(month: Int) -> String{
    if(month == 1){
        return "Jan."
    }
    else if (month == 2){
        return "Feb."
    }
    else if (month == 3){
        return "Mar."
    }
    else if (month == 4){
        return "Apr."
    }
    else if (month == 5){
        return "Jun."
    }
    else if (month == 6){
        return "Jun."
    }
    else if (month == 7){
        return "Jul."
    }
    else if (month == 8){
        return "Aug."
    }
    else if (month == 9){
        return "Sep."
    }
    else if (month == 10){
        return "Oct."
    }
    else if (month == 11){
        return "Nov."
    }
    else{
        return "Dec."
    }
}

func createAdvancedTallyCell(cell: TallyCell, toolBar: UIToolbar, tag: Int, keyboardType: UIKeyboardType){
    cell.input.inputAccessoryView = toolBar
    cell.input.tag = tag
    cell.input.keyboardType = keyboardType
}

func integer(from textField: UITextField) -> Int {
    guard let text = textField.text, let number = Int(text) else {
        return 0
    }
    return number
}

func containsLetters(input: String) -> Bool {
   for chr in input {
      if ((chr >= "a" && chr <= "z") || (chr >= "A" && chr <= "Z") ) {
         return true
      }
   }
   return false
}

