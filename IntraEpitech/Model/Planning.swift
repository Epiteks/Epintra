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
	
    /// Know the type of the associated calendar because they have different behaviours
    ///
    /// - all: Calendar accessed from everyone
    /// - personal: Restricted calendar
    enum CalendarType {
        case all, personal
    }
    
    /// Know the type of the event. If it is an event where we should register or not
    ///
    /// - normal: Normal event with no particular registration
    /// - slots: Slots registration
    enum EventType {
        case normal, slots
    }
    
    /// Type of the associated calendar
    let calendarType: CalendarType!
    
    /// Type of the event
    let eventType: EventType!
    
	/// Title of the module event, nil if event is personal
    var titleModule: String?
    
	/// When the event starts
	var startTime: Date!
    
	/// When the event ends
	var endTime: Date?
	
    /// Number of registered students 🚧
    var totalStudentsRegistered: Int?
	
    /// Student can register to event
    var allowRegister: Bool?
    
    /// Student can enter its token
    var allowToken: Bool?
    
    /// Student status, if he is registered or not
    var eventRegisteredStatus: String?
	
    /// Type code of the event (used for the colorizaration)
    var eventTypeCode: String?
    
    /// Title of the type (Workshop, etc...)
    var typeTitle: String?
	
    /// 🚧
    var actiTitle: String?
	
    /// 🚧
    var codeActi: String?

    /// Only there for personal events...
    var title: String?

    /// Group id to register to slots with a group
    var groupID: Int?
    
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
    
    /*
    ** Get-only properties
    */
    
    var isRegistered: Bool {
        return self.eventRegisteredStatus == "registered"
    }
    
    var isNotRegistered: Bool {
        return self.eventRegisteredStatus == "false"
    }
    
    var wasPresent: Bool {
        return self.eventRegisteredStatus == "present"
    }
    
    var wasAbsent: Bool {
        return self.eventRegisteredStatus == "failed" || self.eventRegisteredStatus == "absent"
    }
    
    var canEnterToken: Bool {
        return self.allowToken == true && self.eventRegisteredStatus == "registered"
    }
    
    var canRegister: Bool {
        
        if self.calendarType == .personal, let startAt = self.startTime, startAt > Date(), self.isNotRegistered == true {
            return true
        }
        
        if self.moduleRegistered == true && self.eventRegisteredStatus == "false" && self.allowRegister! == true && room != nil && room?.seats != nil {
            return true
        }
        return false
    }
    
    var canUnregister: Bool {
        
        if self.calendarType == .personal, let startAt = self.startTime, startAt > Date(), self.eventRegisteredStatus == "registered" {
            return true
        }
        
        if self.moduleRegistered == true && self.eventRegisteredStatus == "registered" && self.allowRegister! == true {
            return true
        }
        return false
    }
    
	override init(dict: JSON) {

        // Event from a personal calendar
        if let calendarType = dict["calendar_type"].string, calendarType == "perso" {
            self.calendarType = .personal
            self.calendarID = dict["id_calendar"].intValue
            self.eventID = dict["id"].intValue
        } else {
            self.calendarType = .all
        }
        
        if dict["type_code"].string == "rdv" {
            self.eventType = .slots
        } else {
            self.eventType = .normal
        }
        
        super.init(dict: dict)
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")

        self.title = dict["title"].stringValue
        
		titleModule = dict["titlemodule"].stringValue
		startTime = dateFormat.date(from: dict["start"].stringValue)
		endTime = dateFormat.date(from: dict["end"].stringValue)
		
        self.totalStudentsRegistered = dict["total_students_registered"].intValue
		
        self.allowRegister = dict["allow_register"].boolValue
		self.allowToken = dict["allow_token"].boolValue

		self.eventRegisteredStatus = dict["event_registered"].stringValue
		self.eventTypeCode = dict["type_code"].string
		typeTitle = dict["type_title"].stringValue
		actiTitle = dict["acti_title"].stringValue
		codeModule = dict["codemodule"].stringValue
		codeActi = dict["codeacti"].stringValue
		codeEvent = dict["codeevent"].stringValue
		codeInstance = dict["codeinstance"].stringValue
		self.room = Room(dict: dict["room"])
		moduleRegistered = dict["module_registered"].boolValue
		isRdv = dict["is_rdv"].intValue
		rdvGroupRegistered = dict["rdv_group_registered"].stringValue
		rdvIndividuelRegistered = dict["rdv_indiv_registered"].stringValue
		past = dict["past"].boolValue
		semester = dict["semester"].intValue
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
    
    /// Get URL data, needed for all planning API calls
    ///
    /// - Returns: data
    func requestURLData() -> String {
        if self.calendarType == .all {
            return String(format: "?year=%@&module=%@&instance=%@&activity=%@&event=%@", self.scolaryear!, self.codeModule!, self.codeInstance!, self.codeActi!, self.codeEvent!)
        } else {
            return String(format: "?calendar=%i&event=%i", self.calendarID!, self.eventID!)
        }
    }
}

func == (left: Planning, right: Planning) -> Bool {
    
    if left.calendarType == right.calendarType && left.calendarID == right.calendarID && left.eventID == right.eventID && left.codeEvent == right.codeEvent && left.codeActi == right.codeActi && left.codeInstance == right.codeInstance {
        return true
    }
    return false
}
