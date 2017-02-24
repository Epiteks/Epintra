//
//  CalendarManager.swift
//  Epintra
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

    func insert(planning: Planning, completion: @escaping (Result<Any?>) -> Void) {

        guard let calendarIdentifier = ApplicationManager.sharedInstance.defaultCalendarIdentifier else {
            completion(Result.failure(type: .noCalendarSelected, message: NSLocalizedString("NoCalendarSelected", comment: "")))
            return
        }

        let eventStore = EKEventStore()

        guard let defaultCalendar = eventStore.calendar(withIdentifier: calendarIdentifier) else {
            completion(Result.failure(type: .calendarNotExists, message: NSLocalizedString("NoCalendar", comment: "")))
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
            completion(Result.failure(type: .unauthorizedByUser, message: NSLocalizedString("NoCalendar", comment: "")))
            return
        }
        completion(Result.success(nil))
    }

    func insert(slot: Slot, completion: @escaping (Result<Any?>) -> Void) {

        guard let calendarIdentifier = ApplicationManager.sharedInstance.defaultCalendarIdentifier else {
            completion(Result.failure(type: .noCalendarSelected, message: NSLocalizedString("NoCalendarSelected", comment: "")))
            return
        }

        let eventStore = EKEventStore()

        guard let defaultCalendar = eventStore.calendar(withIdentifier: calendarIdentifier) else {
            completion(Result.failure(type: .calendarNotExists, message: NSLocalizedString("NoCalendar", comment: "")))
            return
        }

        let event = EKEvent(eventStore: eventStore)
        event.calendar = defaultCalendar

        event.title = slot.appointment?.planningEvent?.actiTitle ?? ""
        event.startDate = slot.date!
        event.endDate = slot.date!.addingTimeInterval(Double(slot.duration) * 60.0)

        event.notes = slot.appointment?.blockTitle

        if let room = slot.appointment?.planningEvent?.room?.getRoomCleaned() {
            event.location = room
        }

        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
        } catch {
            completion(Result.failure(type: .unauthorizedByUser, message: NSLocalizedString("NoCalendar", comment: "")))
            return
        }
        completion(Result.success(nil))
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

    /// Get specific calendar based on its idenrtifier
    ///
    /// - Parameter identifier: calendar identifier
    /// - Returns: matching calendar if found
    class func getCalendar(forIdentifier identifier: String) -> EKCalendar? {

        let calendars = EKEventStore().calendars(for: EKEntityType.event)
        
        for calendar in calendars {
            if calendar.calendarIdentifier == identifier {
                return calendar
            }
        }
        
        return nil
    }
    
}
