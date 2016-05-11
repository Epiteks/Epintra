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
	
	var _scolaryear :String?
	var _codemodule :String?
	var _codeinstance :String?
	var _title :String?
	var _semester :String?
	var _grade :String?
	var _credits :String?
	
	var _begin :String?
	var _end :String?
	var _endRegister :String?
	var _registered :Bool?
	var _activities = [Project]()
	
	init(dict :JSON) {
		_scolaryear = dict["scolaryear"].stringValue
		_codemodule = dict["codemodule"].stringValue
		_codeinstance = dict["codeinstance"].stringValue
		_title = dict["title"].stringValue
		_semester = dict["semester"].stringValue
		_grade = dict["grade"].stringValue
		_credits = dict["credits"].stringValue
	}
	
	init(detail :JSON) {
		_scolaryear = detail["scolaryear"].stringValue
		_codemodule = detail["codemodule"].stringValue
		_codeinstance = detail["codeinstance"].stringValue
		_title = detail["title"].stringValue
		_semester = detail["semester"].stringValue
		_grade = detail["student_grade"].stringValue
		_credits = detail["credits"].stringValue
		
		_begin = detail["begin"].stringValue
		_end = detail["end"].stringValue
		_endRegister = detail["end_register"].stringValue
		_registered = detail["student_registered"].boolValue
		
		let arr = detail["activites"].arrayValue
		
		for tmp in arr {
			_activities.append(Project(detail: tmp))
		}
		
	}
}
