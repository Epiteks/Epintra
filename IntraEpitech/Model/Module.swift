//
//  Module.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Module: BasicInformation {
	
	var title: String?
	var semester: String?
	var grade: String?
	var credits: String?
	
	var begin: String?
	var end: String?
	var endRegister: String?
	var registered: Bool?
	var activities = [Project]()
    var registeredStudents: [RegisteredStudent]?
	
	override init(dict: JSON) {
        
		super.init(dict: dict)
        
		title = dict["title"].stringValue
		semester = dict["semester"].stringValue
		grade = dict["grade"].stringValue
		credits = dict["credits"].stringValue
	}
    
    func setAllData(detail: JSON) {
        self.begin = detail["begin"].stringValue
        self.end = detail["end"].stringValue
        self.endRegister = detail["end_register"].stringValue
        self.registered = detail["student_registered"].boolValue
        
        self.activities = [Project]()
        
        let arr = detail["activites"].arrayValue
        
        for tmp in arr {
            let proj = Project(detail: tmp)
            proj.addModuleData(module: self)
            self.activities.append(proj)
        }

    }
    
    func getDetails(completion: @escaping (Result<Any?>) -> Void) {
        
        modulesRequests.details(forModule: self) { (result) in
            switch (result) {
            case .success(_):
                completion(Result.success(nil))
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                break
            }
        }
    
    }
}
