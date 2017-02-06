//
//  EpirankInformations.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 31/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

/// Used to retrieve informations about epirank data contained in database
class EpirankInformation: Object {
    
    dynamic var promotion: String?
    dynamic var updatedAt: Date?
    
    override static func primaryKey() -> String {
        return "promotion"
    }
    
    init(promo: String, date: Date) {
        super.init()
        self.promotion = promo
        self.updatedAt = date
    }
    
    required init() {
        super.init()
        self.promotion = ""
        self.updatedAt = Date()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
       super.init(realm: realm, schema: schema)
    }
    
    func needsNewerData() -> Bool {
        
        /// Guess when the data was updated on server-side
        guard let guessedUpdatedDate = self.updatedAt?.addingTimeInterval(60 * 60 * 24) else { // Add 24 hour to be sure new data was generated
            return true
        }
        // Check if current date can have new data
        return guessedUpdatedDate < Date()
    }
}
