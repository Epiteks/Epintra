//
//  RealmManager.swift
//  Epintra
//
//  Created by Maxime Junger on 28/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager<T: Object> {
    
    var realm: Realm?
    
    /// Initializer
    ///
    /// - Throws: throws if realm could not init
    init() throws {
        do {
            try self.realm = Realm()
        } catch {
            log.error("Realm launch failed")
        }
    }
    
    /// Save an element is specific realm file
    ///
    /// - Parameter element: element T to save
    func save(element: T) {
        do {
            // Try writing
            try realm?.write {
                // Add object to Realm, update if needed
                realm?.add(element, update: true)
            }
        } catch {
            log.error("Cannot write on Realm")
        }
    }
    
    /// Save multiple elements in realm files
    ///
    /// - Parameter elements: array of elements T
    func save(elements: [T]) {
        // Add all elements to realm
        for tmp in elements {
            do {
                // Try writing
                try realm?.write {
                    // Add object to Realm, update if needed
                    realm?.add(tmp, update: true)
                }
            } catch {
                log.error("Cannot write on Realm")
            }
        }
    }
    
    /// Retrieve elements stored in Realm using an optinal predicate
    ///
    /// - Parameter query: NSPredicate used for filtering data
    /// - Returns: All results
    func retrieveElements(withPredicate query: NSPredicate?) -> Results<T>? {
        if let elements = realm?.objects(T.self) {
            return query != nil ? elements.filter(query!) : elements
        }
        return nil
    }
}
