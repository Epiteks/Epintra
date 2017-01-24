//
//  AppointmentEvent.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 13/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppointmentEvent: BasicInformation {
	
	var codeActi: String?
	var registeredByBlock: Bool?
	var slots: [Appointment]?
	var groupId: String?
	var registered: Bool?
	var studentRegistered: String?
	
	var eventName: String?
	var eventStart: Date?
	var eventEnd: Date?
	
	override init(dict: JSON) {
        super.init(dict: dict)
		codeActi = dict["codeacti"].stringValue
		registeredByBlock = dict["registered_by_block"].boolValue
		groupId = dict["group"]["id"].stringValue
		registered = dict["group"]["inscrit"].boolValue
		studentRegistered = dict["student_registered"].stringValue
	}
	
	func addAppointments(_ dict: JSON) {
		self.slots = [Appointment]()
		
		var slots = dict["slots"].arrayValue
		
		if (slots.count == 1) {
			slots = dict["slots"]["slots"].arrayValue
		}
		
		for eventSlots in slots {
			
			let slots = eventSlots["slots"]
			
			for tmpA in slots.arrayValue {
				let tmp = Appointment(dict: tmpA)
				tmp.date?.addingTimeInterval(TimeInterval(-1))
				if ((tmp.date as NSDate?)?.earlierDate(eventStart!) == eventStart && (tmp.date as NSDate?)?.laterDate(eventEnd!) == eventEnd) {
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
