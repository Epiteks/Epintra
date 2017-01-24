//
//  Planning.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Planning: BasicInformation {
	
    enum EventType {
        case all, personal
    }
    
    let type: EventType!
    
	var titleModule: String?
	var startTime: Date?
	var endTime: Date?
	var totalStudentsRegistered: Int?
	var allowRegister: Bool?
	var allowToken: Bool?
	var eventRegisteredStatus: String?
	var eventType: String?
	var typeTitle: String?
	var actiTitle: String?
	var codeActi: String?
    var title: String?

	var codeEvent: String?
	var room: Room?
	var moduleRegistered: Bool?
	var isRdv: Int?
	var rdvGroupRegistered: String?
	var rdvIndividuelRegistered: String?
	var past: Bool?
	var semester: Int?
    
    // For personal calendars
    var calendarID: Int?
    var eventID: Int?
    
	override init(dict: JSON) {
        
        if let calendarType = dict["calendar_type"].string, calendarType == "perso" {
            self.type = .personal
            self.calendarID = dict["id_calendar"].intValue
            self.eventID = dict["id"].intValue
        } else {
            self.type = .all
        }
        
        super.init(dict: dict)
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        title = dict["title"].stringValue
		titleModule = dict["titlemodule"].stringValue
		startTime = dateFormat.date(from: dict["start"].stringValue)
		endTime = dateFormat.date(from: dict["end"].stringValue)
		totalStudentsRegistered = dict["total_students_registered"].intValue
		allowRegister = dict["allow_register"].boolValue
		allowToken = dict["allow_token"].boolValue
		eventRegisteredStatus = dict["event_registered"].stringValue
		eventType = dict["type_code"].stringValue
		typeTitle = dict["type_title"].stringValue
		actiTitle = dict["acti_title"].stringValue
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
	
//	func getOnlyDay() -> String {
//		let array = startTime?.components(separatedBy: " ")
//		return array![0]
//	}
//	
	func canEnterToken() -> Bool {
		if (self.allowToken == true && self.eventRegisteredStatus == "registered") {
			return true
		}
		return false
	}
	
	func canRegister() -> Bool {
		
        if self.type == .personal, let startAt = self.startTime, startAt > Date(), self.eventRegisteredStatus != "registered" {
            return true
        }
        
		if self.moduleRegistered == true && self.eventRegisteredStatus == "false" && self.allowRegister! == true && room != nil && room?.seats != nil {
			return true
		}
		return false
	}
	
	func canUnregister() -> Bool {
		
        if self.type == .personal, let startAt = self.startTime, startAt > Date(), self.eventRegisteredStatus == "registered" {
            return true
        }
        
		if self.moduleRegistered == true && self.eventRegisteredStatus == "registered" && self.allowRegister! == true {
			return true
		}
		return false
	}
	
	func isRegistered() -> Bool {
		
		if self.eventRegisteredStatus == "registered" {
			return true
		}
		return false
	}
	
	func isUnregistered() -> Bool {
		
		if self.eventRegisteredStatus == "false" {
			return true
		}
		return false
	}
	
	func wasPresent() -> Bool {
		
		if self.eventRegisteredStatus == "present" {
			return true
		}
		return false
	}
	
	func wasAbsent() -> Bool {
		
		if self.eventRegisteredStatus == "failed" || self.eventRegisteredStatus == "absent" {
			return true
		}
		return false
	}
	
//	func getEventTime() -> (start: String, end: String) {
//		
//		startTime?.toDate().toEventHour()
//		
//		if (rdvGroupRegistered!.characters.count > 0) {
//			let arr = rdvGroupRegistered?.components(separatedBy: "|")
//			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
//		} else if (rdvIndividuelRegistered!.characters.count > 0) {
//			let arr = rdvIndividuelRegistered?.components(separatedBy: "|")
//			return (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
//		} else {
//			return ((startTime?.toDate().toEventHour())!, (endTime?.toDate().toEventHour())!)
//		}
//	}
	
//	init(appointment: AppointmentEvent) {
//        super.init()
//		scolaryear = appointment.scolaryear!
//		codeModule = appointment.codeModule!
//		codeActi = appointment.codeActi!
//		codeInstance = appointment.codeInstance!
//	}
    
//    func requestData() -> [String: String] {
//        
//        let parameters: [String: String] = [
//            "year": self.scolaryear!,
//            "module": self.codeModule!,
//            "instance": self.codeInstance!,
//            "activity": self.codeActi!,
//            "event": self.codeEvent!
//        ]
//        
//        return parameters
//    }
//    
    func requestURLData() -> String {
        if self.type == .all {
            return String(format: "?year=%@&module=%@&instance=%@&activity=%@&event=%@", self.scolaryear!, self.codeModule!, self.codeInstance!, self.codeActi!, self.codeEvent!)
        } else {
            return String(format: "?calendar=%i&event=%i", self.calendarID!, self.eventID!)
        }
    }
}

func == (left: Planning, right: Planning) -> Bool {
    
    if left.type == right.type && left.calendarID == right.calendarID && left.eventID == right.eventID && left.codeEvent == right.codeEvent && left.codeActi == right.codeActi && left.codeInstance == right.codeInstance {
        return true
    }
    return false
}
