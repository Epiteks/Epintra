//
//  CalendarManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import EventKit

class CalendarManager {
    
	/// Check if the application has the rights to access the calendar.
    /// If the user did not gave them, prompts the request alert.
	///
	/// - Parameter onCompletion: completion function
	class func hasRights(_ onCompletion: @escaping (Result<Any?>) -> Void) {
		
		let eventStore = EKEventStore()
		
		switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
		case .authorized:
            onCompletion(Result.success(nil))
		case .denied:
            onCompletion(Result.failure(type: AppError.unauthorizedCalendar, message: "CalendarAccessDenied"))
		case .notDetermined:
            // Request access for calendar
			eventStore.requestAccess(to: EKEntityType.event) { (granted: Bool, _) in
				if (granted) { // Authorized
                    onCompletion(Result.success(nil))
				} else { // Denied
					onCompletion(Result.failure(type: AppError.unauthorizedCalendar, message: "CalendarAccessDenied"))
				}
			}
        case .restricted:
            onCompletion(Result.failure(type: AppError.unauthorizedCalendar, message: "CalendarAccessRestricted"))
		}
	}
    
	func createEvent(_ planning: Planning, onCompletion:  @escaping (Bool, String) -> Void) {
        
		// 1
//		let eventStore = EKEventStore()
//		
//		if (ApplicationManager.sharedInstance.defaultCalendar == nil) {
//			onCompletion(false, "NoDefaultCalendar")
//			return
//		} else if ((eventStore.calendar(withIdentifier: ApplicationManager.sharedInstance.defaultCalendar!)) != nil) {
//			onCompletion(false, "DefaultCalendarWrong")
//			return
//		}
//		
//		// 2
//		switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
//		case .authorized:
//			insertEvent(eventStore, planning: planning) { (isOk: Bool) in
//				onCompletion(isOk, "SomethingDidntWorkedCorrectly")
//			}
//			break
//		case .denied:
//			print("Access denied")
//			onCompletion(false, "CalendarAccessDenied")
//			break
//		case .notDetermined:
//			eventStore.requestAccess(to: EKEntityType.event) { (granted: Bool, _) in
//				if (granted) {
//					self.insertEvent(eventStore, planning: planning) { (isOk: Bool) in
//						onCompletion(isOk, "SomethingDidntWorkedCorrectly")
//					}
//				} else {
//					print("Access denied")
//					onCompletion(false, "CalendarAccessDenied")
//				}
//			}
//			break
//		default:
//			print("Case Default")
//		}
	}
    
	func inser(planning: Planning, onCompletion: (Bool) -> Void) {
        
        guard let calendarIdentifier = ApplicationManager.sharedInstance.defaultCalendarIdentifier else {
            // TODO No selected calendar
            log.warning("There was no selected calendar")
            return
        }
        
        let eventStore = EKEventStore()
        
        guard let defaultCalendar = eventStore.calendar(withIdentifier: calendarIdentifier) else {
            // TODO wrong calender
            log.warning("Wrong calendar selected")
            return
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = defaultCalendar
        
        event.title = planning.actiTitle!
        event.startDate = planning.startTime!
        event.endDate = planning.endTime!
        
        if (planning.room != nil) {
            event.location = planning.room!.getRoomCleaned()
        }
        
        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
            
        } catch {
            
            // TODO complete error
           
        }
        
        // TODO complete OK
        
	}
    
	/// Retrieve all calendars available for creating events
	///
	/// - Returns: calendars
	func getAllCalendars() -> [EKCalendar] {
		
		let calendars = EKEventStore().calendars(for: EKEntityType.event)
		var arr = [EKCalendar]()
		
		for calendar in calendars {
			if (calendar.allowsContentModifications == true) {
				arr.append(calendar)
			}
		}
        
		return arr
	}
	
}
