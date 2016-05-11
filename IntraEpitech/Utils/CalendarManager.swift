//
//  CalendarManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import EventKit

class CalendarManager: NSObject {
	
	//	func checkRights() {
	//		
	//		// 1
	//		let eventStore = EKEventStore()
	//		
	//		// 2
	//		switch (EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)) {
	//		case .Authorized:
	//			insertEvent(eventStore)
	//		case .Denied:
	//			println("Access denied")
	//		case .NotDetermined:
	//			// 3
	//			eventStore.requestAccessToEntityType(EKEntityType.Event, completion:
	//				{[weak self] (granted: Bool, error: NSError!) -> Void in
	//					if granted {
	//						self!.insertEvent(eventStore)
	//					} else {
	//						println("Access denied")
	//					}
	//				})
	//		default:
	//			println("Case Default")
	//		}
	//	}
	
	func hasRights(onCompletion :(Bool, String?)->()) {
		
		let eventStore = EKEventStore()
		var res = false
		var mess = "CalendarAccessDenied"		
		
		switch (EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)) {
		case .Authorized:
			res = true
			onCompletion(res, mess)
			break
		case .Denied:
			res = false
			mess = "CalendarAccessDenied"
			onCompletion(res, mess)
			break
		case .NotDetermined:
			eventStore.requestAccessToEntityType(EKEntityType.Event) { (granted :Bool, error :NSError?) in
				if (granted) {
					res = true
				}
				else {
					res = false
					mess = "CalendarAccessDenied"
				}
				onCompletion(res, mess)
			}
			break
		default:
			print("Case Default")
		}
		
	}
	
	func createEvent(planning :Planning, onCompletion : (Bool, String) -> ()) {
		// 1
		let eventStore = EKEventStore()
		
		if (ApplicationManager.sharedInstance._defaultCalendar == nil) {
			onCompletion(false, "NoDefaultCalendar")
			return
		}
		else if ((eventStore.calendarWithIdentifier(ApplicationManager.sharedInstance._defaultCalendar!)) != nil) {
			onCompletion(false, "DefaultCalendarWrong")
			return
		}
		
		// 2
		switch (EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)) {
		case .Authorized:
			insertEvent(eventStore, planning: planning) { (isOk :Bool) in
				onCompletion(isOk, "SomethingDidntWorkedCorrectly")
			}
			break
		case .Denied:
			print("Access denied")
			onCompletion(false, "CalendarAccessDenied")
			break
		case .NotDetermined:
			eventStore.requestAccessToEntityType(EKEntityType.Event) { (granted :Bool, error :NSError?) in
				if (granted) {
					self.insertEvent(eventStore, planning: planning) { (isOk :Bool) in
						onCompletion(isOk, "SomethingDidntWorkedCorrectly")
					}
				}
				else {
					print("Access denied")
					onCompletion(false, "CalendarAccessDenied")
				}
			}
			break
		default:
			print("Case Default")
		}
	}
	
	func insertEvent(store: EKEventStore, planning :Planning, onCompletion :(Bool) -> ()) {
		// 1
		let calendars = store.calendarsForEntityType(EKEntityType.Event)
		
		for calendar in calendars {
			// 2
			if calendar.title == ApplicationManager.sharedInstance._defaultCalendar {
				// 3
				
				var startDate = NSDate()
				var endDate = NSDate()
				
				if (planning._rdvGroupRegistered!.characters.count > 0)
				{
					let arr = planning._rdvGroupRegistered?.componentsSeparatedByString("|")
					//					let resp = (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
					startDate = arr![0].toDate()
					endDate = arr![1].toDate()
					
				}
				else if (planning._rdvIndividuelRegistered!.characters.count > 0) {
					let arr = planning._rdvIndividuelRegistered?.componentsSeparatedByString("|")
					startDate = arr![0].toDate()
					endDate = arr![1].toDate()
					
				}
				else {
					startDate = (planning._startTime?.toDate())!
					// 2 hours
					endDate = (planning._endTime?.toDate())!
				}
				// 4
				
				// Create Event
				let event = EKEvent(eventStore: store)
				event.calendar = calendar
				
				event.title = planning._actiTitle!
				event.startDate = startDate
				event.endDate = endDate
				
				if (planning._room != nil) {
					event.location = planning._room!.getRoomCleaned()
				}
				
				// 5
				// Save Event in Calendar
				
				do {
					try store.saveEvent(event, span: EKSpan.ThisEvent)
					
				}
				catch {
					onCompletion(false)
				}
				onCompletion(true)
				
			}
		}
	}
	
	func getAllCalendars() -> [String] {
		
		let calendars = EKEventStore().calendarsForEntityType(EKEntityType.Event)
		//EKCalendar
		
		var arr = [String]()
		
		for calendar in calendars {
			// 2
			if (calendar.allowsContentModifications == true) {
				arr.append(calendar.title)
			}
			
		}
		return arr
	}
	
}
