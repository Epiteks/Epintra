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
	
	var _scolaryear :String?
	var _codeModule :String?
	var _codeActi :String?
	var _codeInstance :String?
	var _registeredByBlock :Bool?
	var _slots :[Appointment]?
	var _groupId :String?
	var _registered :Bool?
	var _studentRegistered :String?
	
	var _eventName :String?
	var _eventStart :NSDate?
	var _eventEnd :NSDate?
	
	init(dict :JSON) {
		super.init()
		_scolaryear = dict["scolaryear"].string
		_codeModule = dict["codemodule"].stringValue
		_codeActi = dict["codeacti"].stringValue
		_codeInstance = dict["codeinstance"].stringValue
		
		_registeredByBlock = dict["registered_by_block"].boolValue
		
		
		
		//		if (slots.count > 0) {
		//			let eventSlots = slots[0]["slots"]
		//			
		//			for tmp in eventSlots.arrayValue
		//			{
		//				let tmp = Appointment(dict: tmp)
		//				_slots!.append(tmp)
		//			}
		//		}
		
		_groupId = dict["group"]["id"].stringValue
		_registered = dict["group"]["inscrit"].boolValue
		_studentRegistered = dict["student_registered"].stringValue
	}
	
	func addAppointments(dict :JSON) {
		_slots = [Appointment]()
		
		var slots = dict["slots"].arrayValue
		
		if (slots.count == 1) {
			slots = dict["slots"]["slots"].arrayValue
		}
		
		for eventSlots in slots {
			
			let slots = eventSlots["slots"]
			
			for tmpA in slots.arrayValue
			{
				let tmp = Appointment(dict: tmpA)
				tmp._date?.dateByAddingTimeInterval(NSTimeInterval(-1))
				if (tmp._date?.earlierDate(_eventStart!) == _eventStart && tmp._date?.laterDate(_eventEnd!) == _eventEnd) {
					_slots!.append(tmp)
				}
			}
		}
	}
	
	func canRegister() -> Bool {
		if (_studentRegistered! == "") {
			return false
		}
		return true
	}
}

func ==(left :AppointmentEvent, right :AppointmentEvent) -> Bool {
	
	if (left._registered == right._registered) {
		return true
	}
	
	return false
}
