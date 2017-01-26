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
    
    /// Code of the activity
    var codeActi: String!
    
    /// Structure to organize slots easily
    struct SlotsGroup {
        var date: Date!
        var slots: [Slot]!
    }
    
    /// Available slots.
    /// Array of tuple to keep date track
    var slots: [SlotsGroup]? = nil
    
    /// Current group id if slots are for groups projects
    var groupId: Int?
    
    /// Don't remember... 🚧
    // var registeredByBlock: Bool?
    
    /// Is group currently registered
    var registered: Bool!
    
    /// Don't remember... 🚧
    // var studentRegistered: String?
    
    /// Name of the event
    var eventName: String?
    
    /// When the event starts
    var eventStart: Date!
    
    /// When the event ends
    var eventEnd: Date!
    
    init(dict: JSON, eventStart: Date, eventEnd: Date) {
        
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        
        super.init(dict: dict)
        
        self.codeActi = dict["codeacti"].stringValue
        //self.registeredByBlock = dict["registered_by_block"].boolValue
        self.groupId = dict["group"]["id"].int
        self.registered = dict["group"]["inscrit"].boolValue
        //self.studentRegistered = dict["student_registered"].string
        self.eventName = dict["title"].string
        self.addAppointments(dict)
    }
    
    private func addAppointments(_ dict: JSON) {
        
        self.slots = [SlotsGroup]()
        
        // Get all slots for an activity, does not matter of the day
        let slots = dict["slots"].arrayValue
        
        // Iterate through all activities blocks
        for activityBlock in slots {
            
            let slots = activityBlock["slots"]
            
            // Iterate through all slots for a given bvlock
            for jsonSlot in slots.arrayValue {
                
                let tmp = Slot(dict: jsonSlot)
                
                if let tmpDate = tmp.date {
                    // Check if slot is in our event
                    if self.eventStart <= tmpDate && tmpDate < self.eventEnd {
                        self.addToSlots(slot: tmp)
                    }
                }
            }
        }
    }
    
    private func addToSlots(slot: Slot) {
        
        if let slotDate = slot.date {
        
            let index = self.slots?.index(where: { $0.date == slotDate})
            
            if index == nil {
                self.slots?.append(SlotsGroup(date: slotDate, slots: [slot]))
            } else {
                self.slots?[index!].slots.append(slot)
            }
        }
        
    }
    
}

func == (left: AppointmentEvent, right: AppointmentEvent) -> Bool {
    
    if (left.registered == right.registered) {
        return true
    }
    
    return false
}
