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
	
	func hasRights(_ onCompletion :@escaping (Bool, String?)->Void) {
		
		let eventStore = EKEventStore()
		var res = false
		var mess = "CalendarAccessDenied"		
		
		switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
		case .authorized:
			res = true
			onCompletion(res, mess)
			break
		case .denied:
			res = false
			mess = "CalendarAccessDenied"
			onCompletion(res, mess)
			break
		case .notDetermined:
			eventStore.requestAccess(to: EKEntityType.event) { (granted :Bool, _) in
				if (granted) {
					res = true
				} else {
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
	
	func createEvent(_ planning :Planning, onCompletion : @escaping (Bool, String) -> Void) {
		// 1
		let eventStore = EKEventStore()
		
		if (ApplicationManager.sharedInstance.defaultCalendar == nil) {
			onCompletion(false, "NoDefaultCalendar")
			return
		} else if ((eventStore.calendar(withIdentifier: ApplicationManager.sharedInstance.defaultCalendar!)) != nil) {
			onCompletion(false, "DefaultCalendarWrong")
			return
		}
		
		// 2
		switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
		case .authorized:
			insertEvent(eventStore, planning: planning) { (isOk :Bool) in
				onCompletion(isOk, "SomethingDidntWorkedCorrectly")
			}
			break
		case .denied:
			print("Access denied")
			onCompletion(false, "CalendarAccessDenied")
			break
		case .notDetermined:
			eventStore.requestAccess(to: EKEntityType.event) { (granted :Bool, _) in
				if (granted) {
					self.insertEvent(eventStore, planning: planning) { (isOk :Bool) in
						onCompletion(isOk, "SomethingDidntWorkedCorrectly")
					}
				} else {
					print("Access denied")
					onCompletion(false, "CalendarAccessDenied")
				}
			}
			break
		default:
			print("Case Default")
		}
	}
	
	func insertEvent(_ store: EKEventStore, planning :Planning, onCompletion :(Bool) -> Void) {
		// 1
		let calendars = store.calendars(for: EKEntityType.event)
		
		for calendar in calendars {
			// 2
			if calendar.title == ApplicationManager.sharedInstance.defaultCalendar {
				// 3
				
				var startDate = Date()
				var endDate = Date()
				
				if (planning.rdvGroupRegistered!.characters.count > 0) {
					let arr = planning.rdvGroupRegistered?.components(separatedBy: "|")
					//					let resp = (arr![0].toDate().toEventHour(), arr![1].toDate().toEventHour())
					startDate = arr![0].toDate() as Date
					endDate = arr![1].toDate() as Date
					
				} else if (planning.rdvIndividuelRegistered!.characters.count > 0) {
					let arr = planning.rdvIndividuelRegistered?.components(separatedBy: "|")
					startDate = arr![0].toDate() as Date
					endDate = arr![1].toDate() as Date
					
				} else {
					startDate = (planning.startTime?.toDate())! as Date
					// 2 hours
					endDate = (planning.endTime?.toDate())! as Date
				}
				// 4
				
				// Create Event
				let event = EKEvent(eventStore: store)
				event.calendar = calendar
				
				event.title = planning.actiTitle!
				event.startDate = startDate
				event.endDate = endDate
				
				if (planning.room != nil) {
					event.location = planning.room!.getRoomCleaned()
				}
				
				// 5
				// Save Event in Calendar
				
				do {
					try store.save(event, span: EKSpan.thisEvent)
					
				} catch {
					onCompletion(false)
				}
				onCompletion(true)
				
			}
		}
	}
	
	func getAllCalendars() -> [(title: String, color: CGColor)] {
		
		let calendars = EKEventStore().calendars(for: EKEntityType.event)
		//EKCalendar
		
		var arr = [(title: String, color: CGColor)]()
		
		for calendar in calendars {
			// 2
			if (calendar.allowsContentModifications == true) {
				arr.append((calendar.title, calendar.cgColor))
			}
			
		}
		return arr
	}
	
}
