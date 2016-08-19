//
//  AppointmentEvent.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 13/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppointmentEvent: NSObject {
	
	var scolaryear :String?
	var codeModule :String?
	var codeActi :String?
	var codeInstance :String?
	var registeredByBlock :Bool?
	var slots :[Appointment]?
	var groupId :String?
	var registered :Bool?
	var studentRegistered :String?
	
	var eventName :String?
	var eventStart :NSDate?
	var eventEnd :NSDate?
	
	init(dict :JSON) {
		super.init()
		scolaryear = dict["scolaryear"].string
		codeModule = dict["codemodule"].stringValue
		codeActi = dict["codeacti"].stringValue
		codeInstance = dict["codeinstance"].stringValue
		
		registeredByBlock = dict["registered_by_block"].boolValue
		
		
		
		//		if (slots.count > 0) {
		//			let eventSlots = slots[0]["slots"]
		//			
		//			for tmp in eventSlots.arrayValue
		//			{
		//				let tmp = Appointment(dict: tmp)
		//				_slots!.append(tmp)
		//			}
		//		}
		
		groupId = dict["group"]["id"].stringValue
		registered = dict["group"]["inscrit"].boolValue
		studentRegistered = dict["student_registered"].stringValue
	}
	
	func addAppointments(dict :JSON) {
		self.slots = [Appointment]()
		
		var slots = dict["slots"].arrayValue
		
		if (slots.count == 1) {
			slots = dict["slots"]["slots"].arrayValue
		}
		
		for eventSlots in slots {
			
			let slots = eventSlots["slots"]
			
			for tmpA in slots.arrayValue {
				let tmp = Appointment(dict: tmpA)
				tmp.date?.dateByAddingTimeInterval(NSTimeInterval(-1))
				if (tmp.date?.earlierDate(eventStart!) == eventStart && tmp.date?.laterDate(eventEnd!) == eventEnd) {
					self.slots!.append(tmp)
				}
			}
		}
	}
	
	func canRegister() -> Bool {
		if (studentRegistered! == "") {
			return false
		}
		return true
	}
}

	func == (left: AppointmentEvent, right: AppointmentEvent) -> Bool {
	
	if (left.registered == right.registered) {
		return true
	}
	
	return false
}
