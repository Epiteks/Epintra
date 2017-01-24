//
//  RealmStudentInfo.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmStudentInfo {
    
    private var realmStudents: RealmManager<StudentInfo>? = nil
    private var realmInformation: RealmManager<EpirankInformation>? = nil
    
    init() {
        do {
            try self.realmStudents = RealmManager<StudentInfo>()
            try self.realmInformation = RealmManager<EpirankInformation>()
        } catch {
           log.error("Realm init failed")
        }
    }
    
    func save(students: [StudentInfo], updatedAt: EpirankInformation) throws {
        self.realmInformation?.save(element: updatedAt)
        self.realmStudents?.save(elements: students)
    }
    
    func students(byPromotion promotion: String, andCities cities: [String]? = nil) -> [StudentInfo] {
        
        let query = NSPredicate(format: "promo = %@", promotion)
        
        if let students = self.realmStudents?.retrieveElements(withPredicate: query)?.sorted(byProperty: "bachelor", ascending: false) {
            if let allCities = cities, allCities.first != "All" {
                var citiesPredicates = [NSPredicate]()
                for city in allCities {
                    citiesPredicates.append(NSPredicate(format: "city = %@", city))
                }
                let allCitiesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: citiesPredicates)
                let newStudents = students.filter(allCitiesPredicate)
                return Array(newStudents)
            } else {
                return Array(students)
            }
        }
        return [StudentInfo]()
    }
    
    func epirankInformation(forPromo promo: String) -> EpirankInformation? {
        
        let query = NSPredicate(format: "promotion = %@", promo)
        let infos = self.realmInformation?.retrieveElements(withPredicate: query)
        
        return infos?.first
    }
}
    
