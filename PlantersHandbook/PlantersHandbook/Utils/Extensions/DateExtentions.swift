//
//  DateExtentions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-03-08.
//

import Foundation

///DateExtensions.swift - All custom made functions/attributes for Date
extension Date
{
    ///Initalizes a Date object using the format of  "yyyy-MM-dd"
    ///- Parameter dateString: String that is form of  "yyyy-MM-dd"
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
 }
