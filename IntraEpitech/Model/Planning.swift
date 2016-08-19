
//
//  Planning.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Planning: NSObject {
	
	var titleModule :String?
	var startTime :String?
	var endTime :String?
	var totalStudentsRegistered :Int?
	var allowRegister :Bool?
	var allowToken :Bool?
	var eventRegisteredStatus :String?
	var eventType :String?
	var typeTitle :String?
	var actiTitle :String?
	var scolaryear :Int?
	var codeModule :String?
	var codeActi :String?
	var codeEvent :String?
	var codeInstance :String?
	var room :Room?
	var moduleRegistered :Bool?
	var isRdv :Int?
	var rdvGroupRegistered :String?
	var rdvIndividuelRegistered :String?
	var past :Bool?
	var semester :Int?
	
	init(dict :JSON) {
		titleModule = dict["titlemodule"].stringValue
		startTime = dict["start"].stringValue
		endTime = dict["end"].stringValue
		totalStudentsRegistered = dict["total_students_registered"].intValue
		allowRegister = dict["allow_register"].boolValue
		allowToken = dict["allow_token"].boolValue
		eventRegisteredStatus = dict["event_registered"].stringValue
		eventType = dict["type_code"].stringValue
		typeTitle = dict["type_title"].stringValue
		actiTitle = dict["acti_title"].stringValue
		scolaryear = dict["scolaryear"].intValue
		codeModule = dict["codemodule"].stringValue
		codeActi = dict["codeacti"].stringValue
		codeEvent = dict["codeevent"].stringValue
		codeInstance = dict["codeinstance"].stringValue
		room = Room(dict: dict["room"])
		moduleRegistered = dict["module_registered"].boolValue
		isRdv = dict["is_rdv"].intValue
		rdvGroupRegistered = dict["rdv_group_registered"].stringValue
		rdvIndividuelRegistered = dict["rdv_indiv_registered"].stringValue
		past = dict["past"].boolValue
		semester = dict["semester"].intValue
	}
	
	func getOnlyDay() -> String {
		let array = startTime?.componentsSeparatedByString(" ")
		return array![0]
	}
	
	func canEnterToken() -> Bool {
		if (self.allowToken == true && self.eventRegisteredStatus == "registered") {
			return true
		}
		return false
	}
	
	func canRegister() -> Bool {
		
		if (self.moduleRegistered == true && self.eventRegisteredStatus == "false" && self.allowRegister! == true && room != nil && room?.seats != nil) {
			return true
		}
		return false
	}
	
	func canUnregister() -> Bool {
		
		if (self.moduleRegistered == true && self.eventRegisteredStatus == "registered" && self.allowRegister! == true) {
			return true
		}
		return false
	}
	
	func isRegistered() -> Bool {
		
		if (self.eventRegisteredStatus == "registered") {
			return true
		}
		return false
	}
	
	func isUnregistered() -> Bool {
		
		if (self.eventRegisteredStatus == "false") {
			return true
		}
		return false
	}
	
	func wasPresent() -> Bool {
		
		if (self.eventRegisteredStatus == "present") {
			return true
		}
		return false
	}
	
	func wasAbsent() -> Bool {
		
		if (self.eventRegisteredStatus == "failed" || self.eventRegisteredStatus == "absent") {
			return true
		}
		return false
	}
	
	func getEventTime() -> (start :String, end :String) {
		
		startTime?.toDate().toEventHour()
		
		if (rdvGroupRegistered!.characters.count > 0) {
			let arr = rdvGroupRegistered?.componentsSeparatedByString("|")
			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
		} else if (rdvIndividuelRegistered!.characters.count > 0) {
			let arr = rdvIndividuelRegistered?.componentsSeparatedByString("|")
			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
		} else {
			return ((startTime?.toDate().toEventHour())!, (endTime?.toDate().toEventHour())!)
		}
	}
	
	init(appointment :AppointmentEvent) {
		scolaryear = Int(appointment.scolaryear!)
		codeModule = appointment.codeModule!
		codeActi = appointment.codeActi!
		codeInstance = appointment.codeInstance!
		
	}
	
}
