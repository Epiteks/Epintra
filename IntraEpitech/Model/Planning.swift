
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
	
	var _titleModule :String?
	var _startTime :String?
	var _endTime :String?
	var _totalStudentsRegistered :Int?
	var _allowRegister :Bool?
	var _allowToken :Bool?
	var _eventRegisteredStatus :String?
	var _eventType :String?
	var _typeTitle :String?
	var _actiTitle :String?
	var _scolaryear :Int?
	var _codeModule :String?
	var _codeActi :String?
	var _codeEvent :String?
	var _codeInstance :String?
	var _room :Room?
	var _moduleRegistered :Bool?
	var _isRdv :Int?
	var _rdvGroupRegistered :String?
	var _rdvIndividuelRegistered :String?
	var _past :Bool?
	var _semester :Int?
	
	init(dict :JSON)
	{
		_titleModule = dict["titlemodule"].stringValue
		_startTime = dict["start"].stringValue
		_endTime = dict["end"].stringValue
		_totalStudentsRegistered = dict["total_students_registered"].intValue
		_allowRegister = dict["allow_register"].boolValue
		_allowToken = dict["allow_token"].boolValue
		_eventRegisteredStatus = dict["event_registered"].stringValue
		_eventType = dict["type_code"].stringValue
		_typeTitle = dict["type_title"].stringValue
		_actiTitle = dict["acti_title"].stringValue
		_scolaryear = dict["scolaryear"].intValue
		_codeModule = dict["codemodule"].stringValue
		_codeActi = dict["codeacti"].stringValue
		_codeEvent = dict["codeevent"].stringValue
		_codeInstance = dict["codeinstance"].stringValue
		_room = Room(dict: dict["room"])
		_moduleRegistered = dict["module_registered"].boolValue
		_isRdv = dict["is_rdv"].intValue
		_rdvGroupRegistered = dict["rdv_group_registered"].stringValue
		_rdvIndividuelRegistered = dict["rdv_indiv_registered"].stringValue
		_past = dict["past"].boolValue
		_semester = dict["semester"].intValue
	}
	
	func getOnlyDay() -> String {
		let array = _startTime?.componentsSeparatedByString(" ")
		return array![0]
	}
	
	func canEnterToken() -> Bool {
		if (self._allowToken == true && self._eventRegisteredStatus == "registered")
		{
			return true
		}
		return false
	}
	
	func canRegister() -> Bool {
		
		if (self._moduleRegistered == true && self._eventRegisteredStatus == "false" && self._allowRegister! == true && _room != nil && _room?._seats != nil)
		{
			return true
		}
		return false
	}
	
	func canUnregister() -> Bool {
		
		if (self._moduleRegistered == true && self._eventRegisteredStatus == "registered" && self._allowRegister! == true)
		{
			return true
		}
		return false
	}
	
	func isRegistered() -> Bool {
		
		if (self._eventRegisteredStatus == "registered") {
			return true
		}
		return false
	}
	
	func isUnregistered() -> Bool {
		
		if (self._eventRegisteredStatus == "false") {
			return true
		}
		return false
	}
	
	func wasPresent() -> Bool {
		
		if (self._eventRegisteredStatus == "present") {
			return true
		}
		return false
	}
	
	func wasAbsent() -> Bool {
		
		if (self._eventRegisteredStatus == "failed" || self._eventRegisteredStatus == "absent") {
			return true
		}
		return false
	}
	
	func getEventTime() -> (start :String, end :String) {
		
		_startTime?.toDate().toEventHour()
		
		if (_rdvGroupRegistered!.characters.count > 0)
		{
			let arr = _rdvGroupRegistered?.componentsSeparatedByString("|")
			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
		}
		else if (_rdvIndividuelRegistered!.characters.count > 0) {
			let arr = _rdvIndividuelRegistered?.componentsSeparatedByString("|")
			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
		}
		else {
			return ((_startTime?.toDate().toEventHour())!, (_endTime?.toDate().toEventHour())!)
		}
	}
	
	init(appointment :AppointmentEvent) {
		_scolaryear = Int(appointment._scolaryear!)
		_codeModule = appointment._codeModule!
		_codeActi = appointment._codeActi!
		_codeInstance = appointment._codeInstance!
		
	}
	
}
