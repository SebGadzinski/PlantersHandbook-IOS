//
//  StringExtension.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-21.
//

import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    var doubleValue: Double {
            return (self as NSString).doubleValue
    }
    
    // remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    // remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
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
    
    
}
