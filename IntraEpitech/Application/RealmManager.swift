//
//  RealmManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 28/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager {
    
    // swiftlint:disable force_try
    var realm = try! Realm()
    
    func save(students: [StudentInfo], updatedAt: EpirankInformation) throws {
        
        // Add update information value
        try! realm.write {
            realm.add(updatedAt, update: true)
        }
        
        // Add all students to realm
        for tmp in students {
            try! realm.write {
                realm.add(tmp, update: true)
            }
        }
    }
    
    func students(byPromotion promotion: String, andCities cities: [String]? = nil) -> [StudentInfo] {
        
        let query = NSPredicate(format: "promo = %@", promotion)
    
        let students = realm.objects(StudentInfo.self).filter(query).sorted(byProperty: "bachelor", ascending: false)

        if let allCities = cities, allCities.first != "All" {
            var citiesPredicates = [NSPredicate]()
            for city in allCities {
                citiesPredicates.append(NSPredicate(format: "city = %@", city))
            }
            let allCitiesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: citiesPredicates)
            let newStudents = students.filter(allCitiesPredicate)
            return Array(newStudents)
        }
        
        return Array(students)
    }
    
    func epirankInformation(forPromo promo: String) -> EpirankInformation? {
        
        let query = NSPredicate(format: "promotion = %@", promo)
        
        let infos = realm.objects(EpirankInformation.self).filter(query)
        
        return infos.first
    }
}
