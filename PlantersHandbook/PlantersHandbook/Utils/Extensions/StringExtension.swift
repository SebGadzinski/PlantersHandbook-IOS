//
//  StringExtension.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-21.
//

import Foundation

///StringExtensions.swift - All custom made functions/attributes for String
extension String {
    ///Gets subscript of string
    ///- Parameter i: Length of subscript
    ///- Returns: Subscript string
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    ///Converts string to double value
    var doubleValue: Double {
            return (self as NSString).doubleValue
    }
    
    ///Deletes prefix from string if it has it
    ///- Parameter prefix: Unwanted prefix string
    ///- Returns: String with deleted prefix (if found)
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    ///Deletes suffix from string if it has it
    ///- Parameter suffix: Unwanted suffix string
    ///- Returns: String with deleted suffix (if found)
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
    ///Takes the first 25 chars of a string and anything after is replaced by "..."
    ///- Returns: String representing a couple of words from original string
    var firstCoupleWords: String{
        let amountOfChars = 25
        let wordsArr = self.components(separatedBy: " ")
        var finalSentence = ""
        if(wordsArr[0].count > amountOfChars){
            return String(wordsArr[0].prefix(amountOfChars)) + "..."
        }
        if(wordsArr.count == 0){
            return "Reason..."
        }
        for word in wordsArr {
            if(word.count + finalSentence.count > amountOfChars){
                finalSentence += " " + word.prefix(amountOfChars - finalSentence.count) + "..."
                break
            }
            else{
                finalSentence += " " + word
            }
        }
        return finalSentence
    }
    
    ///Gives a true if string contains a boolean
    ///- Returns: Boolean if string contains letters
    func containsLetters() -> Bool {
       for chr in self {
          if ((chr >= "a" && chr <= "z") || (chr >= "A" && chr <= "Z") ) {
             return true
          }
       }
       return false
    }

    ///Gives a true if string is a name
    ///- Returns: Boolean if string is name
    func isName() -> Bool {
        if(self == ""){ return false}
        for chr in self {
           if (chr == "@") {
              return false
           }
        }
        return true
    }
    
}
