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
    var groupID: Int?
    
    /// Don't remember... 🚧
    // var registeredByBlock: Bool?
    
    /// Is group currently registered
    var registered: Bool!
    
    /// Is student registered to another slot
    var studentRegistered: Bool!
    
    /// Name of the event
    var eventName: String?
    
    /// When the event starts
    var eventStart: Date!
    
    /// When the event ends
    var eventEnd: Date!

    /// Title for block, used for some descriptions
    var blockTitle: String?

    var canRegisterToInstance: Bool!
    
    var currentMasterEmail: String? = nil
    var currentMembersEmail: [String]? = nil
    
    var canRegister: Bool {
        return /*self.studentRegistered == false &&*/self.canRegisterToInstance == true
    }
    
    init(dict: JSON, eventStart: Date, eventEnd: Date, eventCodeAsked: String) {
        
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        
        super.init(dict: dict)
        
        self.codeActi = dict["codeacti"].stringValue
        //self.registeredByBlock = dict["registered_by_block"].boolValue
        
        self.studentRegistered = dict["student_registered"].boolValue
        
        self.canRegisterToInstance = dict["student_registered"].boolValue
        
        self.eventName = dict["title"].string
        
        let groupJSON = dict["group"]
        self.groupID = groupJSON["id"].int
        self.registered = groupJSON["inscrit"].boolValue
        self.currentMasterEmail = groupJSON["master"].string
        
        if let members = groupJSON["members"].array {
            
            self.currentMembersEmail = [String]()
            
            for memberJSON in members {
                self.currentMembersEmail?.append(memberJSON.stringValue)
            }
        }
        
        self.addAppointments(dict, eventCodeAsked: eventCodeAsked)
    }
    
    private func addAppointments(_ dict: JSON, eventCodeAsked: String) {
        
        self.slots = [SlotsGroup]()
        
        // Get all slots for an activity, does not matter of the day
        let slots = dict["slots"].arrayValue
        
        // Iterate through all activities blocks
        for activityBlock in slots {
            
            let slots = activityBlock["slots"]

            let codeEvent = activityBlock["codeevent"].stringValue
            
            if codeEvent != eventCodeAsked {
                continue
            }
            
            self.blockTitle = activityBlock["title"].stringValue
            
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
