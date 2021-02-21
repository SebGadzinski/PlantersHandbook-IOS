//
//  RealmExtensions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import RealmSwift
import Foundation

extension Realm {
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
