//
//  Appointment.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class Appointment: NSObject {
	
	var _date :NSDate?
	var _master :RegisteredStudent?
	var _members :[RegisteredStudent]?
	var _title :String?
	var _id :String?
	
	init(dict :JSON) {
		
		_date = dict["date"].stringValue.toDate()
		
		if (dict["master"] != nil) {
			_master = RegisteredStudent(dict: dict["master"])
			_members = [RegisteredStudent]()
			_members?.append(_master!)
			
			if (dict["members"] != nil) {
				
				let tmp = dict["members"].arrayValue
				for regtmp in tmp {
					_members?.append(RegisteredStudent(dict: regtmp))
				}
				
			}
			
		}
		_title = dict["title"].stringValue
		_id = dict["id"].stringValue
	}
}
