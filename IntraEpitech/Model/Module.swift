//
//  Module.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Module: NSObject {
	
	var scolaryear :String?
	var codemodule :String?
	var codeinstance :String?
	var title :String?
	var semester :String?
	var grade :String?
	var credits :String?
	
	var begin :String?
	var end :String?
	var endRegister :String?
	var registered :Bool?
	var activities = [Project]()
	
	init(dict :JSON) {
		scolaryear = dict["scolaryear"].stringValue
		codemodule = dict["codemodule"].stringValue
		codeinstance = dict["codeinstance"].stringValue
		title = dict["title"].stringValue
		semester = dict["semester"].stringValue
		grade = dict["grade"].stringValue
		credits = dict["credits"].stringValue
	}
	
	init(detail :JSON) {
		scolaryear = detail["scolaryear"].stringValue
		codemodule = detail["codemodule"].stringValue
		codeinstance = detail["codeinstance"].stringValue
		title = detail["title"].stringValue
		semester = detail["semester"].stringValue
		grade = detail["student_grade"].stringValue
		credits = detail["credits"].stringValue
		
		begin = detail["begin"].stringValue
		end = detail["end"].stringValue
		endRegister = detail["end_register"].stringValue
		registered = detail["student_registered"].boolValue
		
		let arr = detail["activites"].arrayValue
		
		for tmp in arr {
			activities.append(Project(detail: tmp))
		}
		
	}
}
