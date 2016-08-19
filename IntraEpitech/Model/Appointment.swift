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
	
	var date :NSDate?
	var master :RegisteredStudent?
	var members :[RegisteredStudent]?
	var title :String?
	var id :String?
	
	init(dict :JSON) {
		
		date = dict["date"].stringValue.toDate()
		
		if (dict["master"] != nil) {
			master = RegisteredStudent(dict: dict["master"])
			members = [RegisteredStudent]()
			members?.append(master!)
			
			if (dict["members"] != nil) {
				
				let tmp = dict["members"].arrayValue
				for regtmp in tmp {
					members?.append(RegisteredStudent(dict: regtmp))
				}
				
			}
			
		}
		title = dict["title"].stringValue
		id = dict["id"].stringValue
	}
}
