//
//  RealmExtensions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import RealmSwift
import Foundation

///RealmExtensions.swift - All custom made functions/attributes for Realm
extension Realm {
    ///Safely open a realm with error checking
    ///Source: https://stackoverflow.com/questions/35376584/why-does-realm-use-try-in-swift
    ///- Parameter configuration: Configuration for realm to open
    ///- Returns: Realm that coresponds to configuration
    static func safeInit(configuration: Realm.Configuration) -> Realm? {
        do {
            let realm = try Realm(configuration: configuration)
            return realm
        }
        catch let error as NSError{
            NSLog("Error: ", error)
        }
        return nil
    }

    ///Safely allows writing anything in a realm
    ///Source: https://stackoverflow.com/questions/35376584/why-does-realm-use-try-in-swift
    ///- Parameter block: Block of code that changes any attribute of a class inside of the realm
    ///- Returns: Error message if an error occured
    func safeWrite(_ block: () -> ()) -> String? {
        do {
            // Async safety, to prevent "Realm already in a write transaction" Exceptions
            if !isInWriteTransaction {
                try write(block)
            }
        } catch let error as NSError{
            NSLog("Error: ", error)
            return error.localizedDescription
        }
        return nil
    }
}
