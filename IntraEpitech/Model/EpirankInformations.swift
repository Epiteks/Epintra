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
    
    dynamic var promotion: String!
    dynamic var updatedAt: Date!
    
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
    
    /// Set new value for promotion update information
    ///
    /// - Parameters:
    ///   - promotion: promotion to update
    ///   - date: date of the update
    //func updated(promotion: String, at date: Date) {

        
        
//        if let data = self.informations.filter(NSPredicate(format: "promotion = %@", promotion)).first {
//            data.updatedAt = date
//        } else {
//            let data = EpirankInformationsData()
//            data.promotion = promotion
//            data.updatedAt = date
//            
//            // swiftlint:disable force_try
//            let realm = try! Realm()
//            try! realm.write {
//                informations.append(data)
//            }
//        }
    //}

    /// Get promotion date up
    ///
    /// - Parameter promotion: promotion to retrieve the value
    /// - Returns: date updated, returns nil if there is no value
//    func dateUpdated(for promotion: String) -> Date? {
//        
//        let all = self.informations
//        
//        for tmp in all {
//            print(tmp)
//        }
//        
//        if let data = self.informations.filter(NSPredicate(format: "promotion = %@", promotion)).first {
//            return data.updatedAt
//        }
//        return nil
//    }
    
    func needsNewerData() -> Bool {
        
        /// Guess when the data was updated on server-side
        let guessedUpdatedDate = self.updatedAt.addingTimeInterval(60 * 60 * 24) // Add 24 hour to be sure new data was generated
        
        // Check if current date can have new data
        return guessedUpdatedDate < Date() ? true : false
    }
    
   

}

class EpirankInformationManager {
    
    class func updated(promotion: String, at date: Date) {
        
        //ApplicationManager.sharedInstance.realmManager
        
    }
    
}
