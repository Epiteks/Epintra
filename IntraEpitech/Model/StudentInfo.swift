//
//  StudentInfo.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 21/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

class StudentInfo: Object {
	
    dynamic var title: String?
	dynamic var login: String?
	dynamic var city: String?
    var bachelor = RealmOptional<Double>()
	dynamic var promo: String?
	
	init(dict: JSON, promo: String) {
        super.init()
        self.title = dict["title"].stringValue
		self.login = dict["login"].stringValue
		self.city = dict["city"].stringValue
        self.bachelor.value = dict["bachelor"].doubleValue
		self.promo = promo
	}
    
    override static func primaryKey() -> String {
        return "login"
    }
    
    override static func indexedProperties() -> [String] {
        return ["city", "promo"]
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}
